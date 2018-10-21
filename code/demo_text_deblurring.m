clc;
clear all;
close all;
addpath(genpath('image'));
addpath(genpath('cho_code'));
addpath(genpath('whyte_code'));

opts.prescale = 1; %%downsampling
opts.xk_iter = 5; %% the iterations
opts.gamma_correct = 1.0;
opts.k_thresh = 20;

filename = 'image/task_3.jpg'; opts.kernel_size = 89;  saturation = 0;
lambda_pixel = 4e-3; lambda_grad = 4e-3; opts.gamma_correct = 2.2;
lambda_tv = 0.002; lambda_l0 = 1e-4; weight_ring = 1;

y = imread(filename);
% y = y(3:end-2,3:end-2,:);
%y = imfilter(y,fspecial('gaussian',5,2),'same','replicate'); 
isselect = 0; %false or true
if isselect ==1
    figure, imshow(y);
    %tips = msgbox('Please choose the area for deblurring:');
    fprintf('Please choose the area for deblurring:\n');
    h = imrect;
    position = wait(h);
    close;
    B_patch = imcrop(y,position);
    y = (B_patch);
else
    y = y;
end
if size(y,3)==3
    yg = im2double(rgb2gray(y));
else
    yg = im2double(y);
end
tic;
[kernel, interim_latent] = blind_deconv(yg, lambda_pixel, lambda_grad, opts);
toc
y = im2double(y);
%% Final Deblur: 
if ~saturation
    %% 1. TV-L2 denoising method
    Latent = ringing_artifacts_removal(y, kernel, lambda_tv, lambda_l0, weight_ring);
else
    %% 2. Whyte's deconvolution method (For saturated images)
    Latent = whyte_deconv(y, kernel);
end
figure; imshow(Latent)
%%
k = kernel - min(kernel(:));
k = k./max(k(:));
imwrite(k,['results\' filename(7:end-4) '_kernel.png']);
imwrite(Latent,['results\' filename(7:end-4) '_result.png']);
imwrite(interim_latent,['results\' filename(7:end-4) '_interim_result.png']);
%%

