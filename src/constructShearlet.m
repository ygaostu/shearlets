function sys = constructShearlet(sz, levels, bigsz)

qmf = design(fdesign.lowpass('N,F3db', 8, 0.5),'maxflat');
qmf = qmf.Numerator;

h0 = qmf;

t = [0, 1, 0; 1, 0, 1; 0, 1, 0] / 4;
h0 = ftrans2(h0, t);
m = (-1).^((1:size(h0, 2)) - ceil(size(h0, 2)/2));
directionalFilter = h0.*repmat(m, [size(h0, 1), 1]);

[ decsys, recsys, W ] = shearlets(sz(1), sz(2), levels, directionalFilter, qmf);

decsys = single(decsys);
recsys = single(recsys);
Weights = single(repmat(W, [size(decsys, 1), size(decsys, 2), 1]));

decsys = fftshift(fftshift(ifft2(ifftshift(ifftshift(decsys, 1), 2)), 1), 2);
recsys = fftshift(fftshift(ifft2(ifftshift(ifftshift(recsys, 1), 2)), 1), 2);

if (exist('bigsz', 'var'))
    decsys = centerpad(decsys, bigsz(1), 1, 0);
    decsys = centerpad(decsys, bigsz(2), 2, 0);
    recsys = centerpad(recsys, bigsz(1), 1, 0);
    recsys = centerpad(recsys, bigsz(2), 2, 0);
    
    % normalize
    w = Weights(1, 1, :);
    w = w.*(sqrt(sz(1)*sz(2))./sqrt(size(decsys, 1)*size(decsys, 2)));
    Weights = repmat(w, [ size(decsys, 1), size(decsys, 2), 1 ]);
end

decsys = ifftshift(ifftshift(decsys, 1), 2);
recsys = ifftshift(ifftshift(recsys, 1), 2);

sys = struct;
sys.dec = single(real(decsys));
sys.rec = single(real(recsys));
sys.w = single(real(Weights));
