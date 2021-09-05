function x = cropedges(x, sz)
    hsz = floor(sz/2);
    if (size(x, 1) > sz(1))
        x = x(ceil(end/2) + (-hsz(1):hsz(1)), :);
%         k = kaiser(size(x, 1), 2);
%         x = x.*repmat(k(:), [1, size(x, 2)]);
    end
    if (size(x, 2) > sz(2))
        x = x(:, ceil(end/2) + (-hsz(2):hsz(2)));
%         k = kaiser(size(x, 2), 2);
%         x = x.*repmat(k(:)', [size(x, 1), 1]);
    end