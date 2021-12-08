clc;
close all;
clear all;

dataFormat = 'PNG'; 

%==========01=========%
dataNameStack{1} = 'bear';
%==========02=========%
dataNameStack{2} = 'cat';
%==========03=========%
dataNameStack{3} = 'pot';
%==========04=========%
dataNameStack{4} = 'buddha';

for testId = 1 : 4
    dataName = [dataNameStack{testId}, dataFormat];
    datadir = ['../pmsData/', dataName];
    bitdepth = 16;
    gamma = 1;
    resize = 1;  
    data = load_datadir_re(datadir, bitdepth, resize, gamma); 

    L = data.s;
    f = size(L, 1);
    [height, width, color] = size(data.mask);
    if color == 1
        mask1 = double(data.mask./255);
    else
        mask1 = double(rgb2gray(data.mask)./255);
    end
    mask3 = repmat(mask1, [1, 1, 3]);
    m = find(mask1 == 1);
    p = length(m);

    %% Standard photometric stereo
    Normal = myPMS(data, m);

    %% Save results "png"
    imwrite(uint8((Normal+1)*128).*uint8(mask3), strcat(dataName, '_Normal.png'));

    %% Save results "mat"
    save(strcat(dataName, '_Normal.mat'), 'Normal');
end
