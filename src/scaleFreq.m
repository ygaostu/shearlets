% for each column scale down frequency response by factor
function y = scaleFreq(x, factor, lpfir)
    if (factor == 1)
        y = x;
        return;
    end
    if (~exist('lpfir', 'var'))
%         % lanczos3
        func = @(x) (abs(x) < 3).*(sin(pi*x) .* sin(pi*x/3) + eps) ./ ((pi^2 * x.^2 / 3) + eps);
        lpfir = func((-3:(1/factor):3))/factor;
        lpfir = lpfir./sum(lpfir(:));
        % nyquist
%         lpfir = 1/factor*sinc(1/factor*(-25:25));
%         lpfir = lpfir.*hamming(numel(lpfir))';

        % kaiser        
%         delta = 1/(2*factor);
%         [ n, Wn, beta, ftype ] = kaiserord([1/factor - delta, 1/factor + delta], ...
%                             [1, 0], [0.01, 0.01]);
% 
%         lpfir = fir1(ceil(n/2)*2, Wn, ftype, kaiser(ceil(n/2)*2 + 1, beta));
%         lpfir = lpfir./sum(lpfir(:));
    end
    
    y = zeros(size(x, 1) + (size(x, 1) - 1)*(factor - 1) + numel(lpfir) - 1, size(x, 2));
    for k = 1:size(x, 2)
        upc = zeros(size(y, 1), 1);
        upc(floor(numel(lpfir)/2) + (1:factor:factor*size(x, 1))) = x(:, k);
        y(:, k) = conv(upc, lpfir, 'same');
    end
