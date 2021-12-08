function N = myPMS(data, m)
%% Parameters
noise_p=0.2; % Remove a specific proportion of noise
% L_render=data.s(10,:); % Light directions for render
% Li_render=data.L(10,:);% Light intensities for render
L_render=[0,0,1]; % Light directions for render
Li_render=[1,1,1]; % Light intensities for render

%% Get Data
l_direction = (data.s)'; % 3*img_num
img_num = size(l_direction, 2);
[height, width, ~] = size(data.mask);
pixel_num = length(m);

%% Get Intensities
I_raw = zeros(pixel_num, img_num);
for i = 1 : img_num
    img = data.imgs{i};
    img = rgb2gray(img); % Convert RGB to intensity using rgb2gray
    img = img(m);
    I_raw(:, i) = img;
end
%% Get Directions
L_raw = l_direction;

%% Sort intensities and remove a specific proportion of noise
[I_sortted,idx]=sort(I_raw,2);
I=I_sortted(:,floor(img_num*noise_p):ceil(img_num*(1-noise_p)));
idx=idx(:,floor(img_num*noise_p):ceil(img_num*(1-noise_p)));

%% Calculate b=albedo*n using least square
b=zeros(pixel_num,3);
for i = 1: pixel_num
    L=L_raw(:,idx(i,:)); % Get valid L according to idx
    b(i,:) = I(i,:) * pinv(L); % least square
end

%% Calculate albedo and normal form b=albedo*n
albedo_col=zeros(height*width,1);
N_col=zeros(height*width, 3);
for i = 1 : pixel_num
    albedo_col(m(i),1) = norm(b(i,:));
    N_col(m(i),1) = (b(i, 1) / albedo_col(m(i),1));
    N_col(m(i),2) = (b(i, 2) / albedo_col(m(i),1));
    N_col(m(i),3) = (b(i, 3) / albedo_col(m(i),1));
end

%% Reshape
albedo= reshape(albedo_col, height, width,1);
N = reshape(N_col, height, width,3);
N(isnan(N)) = 0;

%% Render images
img_rec_col=albedo_col.*N_col*L_render'* Li_render;
% img_rec_col(:,1)=img_rec_col(:,1)/0.2989;
% img_rec_col(:,2)=img_rec_col(:,2)/0.5870;
% img_rec_col(:,3)=img_rec_col(:,3)/0.1140;
img_rec=reshape(img_rec_col, height, width,3);
img_rec=max(img_rec,0);

%% Save results "png" and "mat"
dataName=data.filenames{1}(12:strlength(data.filenames{1})-8);
% albedo=rescale(albedo);
imwrite(albedo, strcat(dataName, '_Albedo.png'));
imwrite(img_rec, strcat(dataName, '_Render.png'));
save(strcat(dataName, '_Albedo.mat'), 'albedo');
