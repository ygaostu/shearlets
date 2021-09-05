% Construction of Shearlet Frame is entirely based on the method presented
% at ShearLab3D. Small modifications are implemented to provide better properties
% for EPI reconstruction.
% For More Details check www.shearlab.org
%  G. Kutyniok, W.-Q. Lim, R. Reisenhofer
%  ShearLab 3D: Faithful Digital SHearlet Transforms Based on Compactly Supported Shearlets.
%  ACM Trans. Math. Software 42 (2016), Article No.: 5.
function [ shearlets, shearletsDual, RMS, wl ] = ...
    shearlets(rows, cols, shearLevels, directionalFilter, quadratureMirrorFilter)
    % convert to single
    directionalFilter = single(directionalFilter);
    quadratureMirrorFilter = single(quadratureMirrorFilter);
        
    %%
    NScales = numel(shearLevels);

    %% compute 1D high and lowpass filters at different scales for wavelet part
    qmfHigh = cell(1,NScales);
    qmfLow = cell(1,size(qmfHigh,2));

    qmfLow{end} = quadratureMirrorFilter;
    qmfHigh{end} = -( (-1).^(1:length(qmfLow{end})) ).*qmfLow{end}; %% mirror QMF

    lowpass = qmfLow{end};
    for j = size(qmfHigh,2)-1:-1:1
        qmfLow{j} = upsample(qmfLow{j+1}, lowpass);
        qmfHigh{j} = upsample(qmfHigh{j+1}, lowpass);
    end

    wl = {qmfLow{1}, qmfHigh{:}};
    
    %% compute bandpass 2D filters for all scales
    bandpass = zeros(rows,cols, NScales, 'single');

    for j = 1:size(qmfHigh,2)
        centr = floor((cols - numel(qmfHigh{j}))/2);
        temp = zeros(rows, cols);
        temp(ceil(rows/2),centr+(1:numel(qmfHigh{j}))) = qmfHigh{j};
        tempfft = fftshift(fftshift(fft2(ifftshift(ifftshift(temp, 1), 2)), 1), 2);
        bandpass(:,:,j)= tempfft;
    end

    lowpass = qmfLow{1};
    lowpass = fftshift(fft2(ifftshift(padarray(lowpass'*lowpass, ...
         [rows - numel(lowpass), cols - numel(lowpass)]/2, 0, 'both'))));

    %% calculate shearing filters
%      directionalFilter = directionalFilter/sum(abs(directionalFilter(:)));
    shearFiltersSet = cell(1, NScales);

    for scale = 1:NScales
        shearLevel = shearLevels(scale);
        
        %% experimental
        dfup = directionalFilter;

        %% squeeze vertical in freq plane
        dfup = scaleFreq(dfup, 2*2^(NScales - scale)*(2^shearLevel));
        
        % squeeze horizontally in freq plane
        dfup = scaleFreq(dfup', 2^(NScales - scale))';
        
        dfup = cropedges(dfup, [rows, cols]);
        
        %% shearing
        nrows = size(dfup, 1);
        ncols = size(dfup, 2);

        maxShear = 2^shearLevel; % range of shears is [0, maxShear] which corresponds to [0, 1]

        shearFilter = zeros(nrows, ncols + floor(nrows/2)*2, 2*maxShear + 1, 'single');
        for rowid = 1:nrows
            row = dfup(rowid, :);
            
            rowsh = spreadupsample(row, (-maxShear:maxShear), maxShear, rowid - ceil(nrows/2))';
            
            sz = floor(size(rowsh, 1)/2);
            shearFilter(rowid, ceil(end/2) + (-sz:sz), :) = rowsh;
        end

        shearFilter = padarray(shearFilter, [ max(floor((rows - size(shearFilter, 1))/2), 0), max(floor((cols - size(shearFilter, 2))/2), 0), 0 ]);
        shearFilter = shearFilter(max(size(shearFilter, 1) - rows, 0)/2 + (1:rows), ...
            max(size(shearFilter, 2) - cols, 0)/2 + (1:cols), :);
        shearFiltersSet{scale} = fftshift(fftshift(fft2(ifftshift(ifftshift(shearFilter, 1), 2)), 1), 2);
    end

    %% Shearlets 
    % RMS - Root Mean Square for Weighting decomposition coefficients
    % DFW - Frequency Domain Dual Construction Weighting Function
    shearlets = zeros(rows, cols, sum(2.^shearLevels + 1) + 1);
    dfw = zeros(rows, cols);
    j = 0;
    for scale = 1:NScales
        for shear = 1:size(shearFiltersSet{scale}, 3)
            sl = shearFiltersSet{scale}(:,:,shear);
            sl = sl.*conj(bandpass(:,:,scale));
            
            if shear <= ceil(size(shearFiltersSet{scale}, 3)/2)
                j = j + 1;
                shearlets(:,:,j) = sl;
            end
            
            if shear == 1 || shear == size(shearFiltersSet{scale}, 3)
                dfw = dfw + abs(sl).^2;
            else
                dfw = dfw + abs(sl).^2 + abs(sl').^2;
            end
        end
    end
    shearlets(:, :, end) = lowpass;
    dfw = dfw + abs(shearlets(:,:,end)).^2;
    
    DFW = repmat(dfw, [1, 1, size(shearlets, 3)]);
    shearletsDual = shearlets./(DFW + eps);
    
    RMS = sqrt(sum(sum(abs(shearlets).^2, 1), 2))./sqrt(size(shearlets, 1)*size(shearlets, 2));
