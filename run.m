addpath('./src');

% maximum disparity range = 8 pixels
% nScale = 3; kSize = 63;

% maximum disparity range = 16 pixels
% nScale = 4; kSize = 127;

% maximum disparity range = 32 pixels
nScale = 5; kSize = 255;

sys = constructShearlet([kSize, kSize], 1:nScale); 
dec = sys.dec;
rec = sys.rec;
w = sys.w;
save(sprintf('shearlet_systems/st_%d_%d_%d', kSize, kSize, nScale), 'dec', 'rec', 'w');