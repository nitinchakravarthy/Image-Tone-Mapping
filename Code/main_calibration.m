clear; clc; 

%%% Assignment 4 - Starter code

% Setting up the input output paths and the parameters
inputDir = '../Images/';
outputDir = '../Results/';

lambda = 50;
Zmin = 0;
Zmax = 255;

calibSetName = '1_Calib_Office';

% Parsing the input images to get the file names and corresponding exposure
% values
[filePaths, exposures, numExposures] = ParseFiles([inputDir, calibSetName]);


% Sample the images
N = (5*255)/(numExposures-1);

I = imread(filePaths{1,1});
[l,b,c] = size(I);
I_r = I(:,:,1);
I_r_vect = I_r(:);

%pixel_array = [];
%count = 1;
%for i = 1:l
%    for j = 1:b
%        pixel_array(count,1) = i; 
%        pixel_array(count,2) = j;
%        count = count +1;
%    end
%end
indices = randperm(size(I_r_vect,1));
indices = indices(1:ceil(N));
% the above indices are the indices in the pixel_array for the corresponding pixels that we will be using 

% now we get the index of the pixel from all the images
Z_r = [];
Z_g = [];
Z_b = [];
count = 1;
for i = 1:size(indices,2)
    for j = 1:size(filePaths,2)
        I = imread(filePaths{1,j});
        I_r = I(:,:,1);
        I_g = I(:,:,2);
        I_b = I(:,:,3);
        I_r_vect = I_r(:);
        I_g_vect = I_g(:);
        I_b_vect = I_b(:);
        %pixelIndex = indices(1,i);
        Z_r(i,j) = I_r_vect(indices(1,i),1);
        Z_g(i,j) = I_g_vect(indices(1,i),1);
        Z_b(i,j) = I_b_vect(indices(1,i),1);
        %Z_r(i,j) = I(pixel_array(pixelIndex,1),pixel_array(pixelIndex,2),1);
        %Z_g(i,j) = I(pixel_array(pixelIndex,1),pixel_array(pixelIndex,2),2);
        %Z_b(i,j) = I(pixel_array(pixelIndex,1),pixel_array(pixelIndex,2),3);
    end
    i = i + 1;
end

%I = imread(filePaths{1,1});
%[l,b,c] = size(I);
%num_pixels = l*b;

    % we need to find the camera response function seperately for all the
    % three channels




% Recover the camera response function using Debevec's optimization code (gsolve.m)
% function handle
w = @triangle;
[g_r,lE_r]=gsolve(Z_r,log(exposures),lambda,w, Zmin, Zmax);
[g_g,lE_g]=gsolve(Z_g,log(exposures),lambda,w, Zmin, Zmax);
[g_b,lE_b]=gsolve(Z_b,log(exposures),lambda,w, Zmin, Zmax);

save('cameracalib1.mat','g_r','g_g','g_b');
%save('cameracalib0.mat','g_r','g_g','g_b');

% Create the triangle function
function w = triangle(z)
    z_min = 0;
    z_max = 255;
    if ( z <= (z_min + z_max)/2)
        w = z - z_min;
    else
        w = z_max - z ; 
    end
end
