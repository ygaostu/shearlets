function [ y, b, n ] = centerpad(x, bigsz, dim, val)
    sz = size(x);
    b = ceil((bigsz - sz(dim))/2);
    
    newsz = sz;
    newsz(dim) = bigsz;
    y = repmat(cast(val, class(x)), newsz);
    
    order = [dim, [1:dim-1, dim+1:numel(sz)]];
    [~, reorder] = sort(order);

    y = permute(y, order);
    x = permute(x, order);
    y(b + (1:sz(dim)), :) = x(:,:);
    y = permute(y, reorder);
    n = sz(dim);