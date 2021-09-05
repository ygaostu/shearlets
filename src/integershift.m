function y = integershift(x, shift, pad)
if pad ~= 0
    if (shift == 0)
        pad = 0;
    end
    y = zeros(1, numel(x) + 2*pad);
    y(pad + shift + (1:numel(x))) = x;
else
    y = 0.*x;
    
    if (shift >= 0)
        y(shift+1:end) = x(1:end-shift);
    else
        y(1:end+shift) = x(1-shift:end);
    end
end