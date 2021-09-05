% shear by rational value
% x - row
% numers - numenator of shearing (vector of values)
% denumer - denumerator
% scaling overall scaling factor
% shears = scaling*(numers/denumer)

function y = spreadupsample(x, numers, denumer, scaling)
    shifts = numers*scaling;             % full shift on upsampled grid
    Bshifts = round(shifts/denumer);     % big shift on regular grid, integer < abs(scaling)
    Sshifts = shifts - Bshifts*denumer;  % small shift on upsampled grid, < denumer

    y = zeros(numel(numers), numel(x) + 2*abs(scaling));

    % filter
    func = @(x) (abs(x) < 3).*(sin(pi*x) .* sin(pi*x/3) + eps) ./ ((pi^2 * x.^2 / 3) + eps);
    lp = func(-3:(1/denumer):3);
    lp = lp./sum(lp(:));
    
    %     
    xup = zeros(1, (numel(x) - 1)*denumer + 1 + numel(lp));
    xup(floor(numel(lp)/2) + floor(denumer/2) + (1:denumer:(numel(x)*denumer))) = x;
    xup = conv(xup, lp, 'same');

    for k = 1:numel(Sshifts)
        sxup = integershift(xup, Sshifts(k), 0);

        sx = conv(sxup, lp, 'same').*denumer;
        
        sx = sx(floor(numel(lp)/2) + floor(denumer/2) + (1:denumer:(numel(x)*denumer)));
        
        t = zeros(1, numel(x) + 2*abs(scaling));
        t(ceil(end/2) + (-floor(numel(sx)/2):floor(numel(sx)/2))) = sx;
        
        y(k, :) = integershift(t, Bshifts(k), 0);
    end