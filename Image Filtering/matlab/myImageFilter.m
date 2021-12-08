function [img1] = myImageFilter(img0, h)
%% Get filter size 
filt_r = size(h,1);
filt_c = size(h,2);

%% padding
pad_r = floor(filt_r/2);
pad_c = floor(filt_c/2);
pad_img = padarray(img0, [pad_r pad_c], 'replicate', 'both');

%% conv
img1 = zeros('like',img0);
for i = 1:size(img0,1) % row
    for j = 1:size(img0,2) % column
        patch = (pad_img(i:i+filt_r-1,j:j+filt_c-1));
        conv_patch = patch.*h;
        if(sum(h,"all")==0) % for edge filter
            img1(i,j) = sum(conv_patch,'all');
        else % for general filter
            img1(i,j) = sum(conv_patch,'all')/sum(h,"all");
        end
    end
end
end
