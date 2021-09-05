function y = upsample(x, lp)
    y = zeros(1, numel(x)*2-1);
    y(1:2:end) = x;
    y = conv(y, lp);