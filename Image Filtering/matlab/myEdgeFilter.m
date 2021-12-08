function [img1] = myEdgeFilter(img0, sigma)

%% Smooth image with the specified Gaussian kernel
hsize = 2 * ceil(3 * sigma) + 1; % The size of the Gaussian filter
gaus = fspecial('gaussian', hsize, sigma);
im = myImageFilter(img0,gaus);

%% Calculate image gradient with the Sobel filter
sobel = fspecial('sobel');
imgx = myImageFilter(im, sobel'); % convolve with x-oriented Sobel filter
imgy = myImageFilter(im, sobel); % convolve with y-oriented Sobel filter
% imshow(sqrt(imgx/max(imgx(:))));
% imshow(sqrt(img/max(imgx(:))));

%% Non-maximum suppression
G_dir = atan(imgy./imgx); % compute direction [-2/pi,2/pi]
% arrange directions into 4 groups
G_dir(G_dir>-pi/8 & G_dir<pi/8) = 0;
G_dir(G_dir>pi/8 & G_dir<3*pi/8) = 45;
G_dir(G_dir>3*pi/8 | G_dir<-3*pi/8) = 90;
G_dir(G_dir>-3*pi/8 & G_dir<-pi/8) = 135;

G_mag = sqrt(imgx.^2+imgy.^2); % compute amplitude (gradient magnitude)

img1= zeros(size(img0,1), size(img0,2));

% get neighbors of each pixel
for i =1:size(im,1)%row
    for j = 1:size(im,2)%column
        mag_current = G_mag(i,j);
        dir_current = G_dir(i,j);
        % if the pixel does not have neighbors, set neighbors=0
        if dir_current == 0
            try mag_n1 = G_mag(i,j-1); catch, mag_n1 = 0; end
            try mag_n2 = G_mag(i,j+1); catch, mag_n2 = 0; end
        elseif dir_current == 45
            try mag_n1 = G_mag(i-1,j+1); catch, mag_n1 = 0; end
            try mag_n2 = G_mag(i+1,j-1); catch, mag_n2 = 0; end
        elseif dir_current == 90
            try mag_n1 = G_mag(i-1,j); catch, mag_n1 = 0; end
            try mag_n2 = G_mag(i+1,j); catch, mag_n2 = 0; end
        elseif dir_current == 135
            try mag_n1 = G_mag(i-1,j-1); catch, mag_n1 = 0; end
            try mag_n2 = G_mag(i+1,j+1); catch, mag_n2 = 0; end
        end
        % perform NMS
        if max([mag_current,mag_n1, mag_n2]) ~= mag_current
            img1(i,j) = 0;
        else
            img1(i,j) = G_mag(i,j);
        end        
    end
end
end
    
                
        
        
