clear; clc;

%%% Assignment 4 - Starter code

% Setting up the input output paths and the parameters
inputDir = '../Images/';
outputDir = '../Results/';

sceneName = '0_Calib_Chapel';
%sceneName = '1_Bicycles';

%sceneName ='0_Calib_Chapel';
%load('cameracalib0.mat')
load('cameracalib1.mat')
%plot([g_g,g_r,g_b])
% Parsing the input images to get the file names and corresponding exposure
% values
[filePaths, exposures, numExposures] = ParseFiles([inputDir, sceneName]);

% Reconstruct the irradiance of the scene using Eq. 6 in the Debevec paper

% import g_r,g_g,g_b here

imgs = [];
for j = 1:size(filePaths,2)
    I = imread(filePaths{1,j});
    imgs(:,:,:,j) = I;
end
l = size(imgs,1);
b = size(imgs,2);

Ei = [];
for r = 1: l
    for c = 1:b 
        % for each pixel
        numerator_r = 0;
        numerator_g = 0;
        numerator_b = 0;
        denomenator_r = 0;
        denomenator_g = 0;
        denomenator_b = 0;
        
        for j = 1:size(imgs,4)
            pix_r = imgs(r,c,1,j)+1;
            pix_g = imgs(r,c,2,j)+1;
            pix_b = imgs(r,c,3,j)+1;
            
            numerator_r = numerator_r + triangle(pix_r)*( g_r(pix_r) - log(exposures(j)) );
            denomenator_r = denomenator_r + triangle(pix_r);
            
            numerator_g = numerator_g + triangle(pix_g)*( g_g(pix_g) - log(exposures(j)) );
            denomenator_g = denomenator_g + triangle(pix_g);
            
            numerator_b = numerator_b + triangle(pix_b)*( g_b(pix_b) - log(exposures(j)) );
            denomenator_b = denomenator_b + triangle(pix_b);
        end
        
        Ei_r = numerator_r/denomenator_r;
        Ei_g = numerator_g/denomenator_g;
        Ei_b = numerator_b/denomenator_b;
        Ei(r,c,1) = Ei_r;
        Ei(r,c,2) = Ei_g;
        Ei(r,c,3) = Ei_b;
    end
end

% Ei is lnEi. So we use exponenet to get just Irradiance
Irr = exp(Ei);

% Tonemap the image using the global operator

finalImg_001 = [];
finalImg_005 = [];
finalImg_01 = [];
finalImg_05 = [];
finalImg = [];

for r = 1: l
    for c = 1:b 

        finalImg_001 (r,c,1) = 0.01*Irr(r,c,1) / (1 + 0.01*Irr(r,c,1));
        finalImg_001 (r,c,2) = 0.01*Irr(r,c,2) / (1 + 0.01*Irr(r,c,2));
        finalImg_001 (r,c,3) = 0.01*Irr(r,c,3) / (1 + 0.01*Irr(r,c,3));
                
        finalImg_005 (r,c,1) = 0.05*Irr(r,c,1) / (1 + 0.05*Irr(r,c,1));
        finalImg_005 (r,c,2) = 0.05*Irr(r,c,2) / (1 + 0.05*Irr(r,c,2));
        finalImg_005 (r,c,3) = 0.05*Irr(r,c,3) / (1 + 0.05*Irr(r,c,3));
        
        finalImg_01 (r,c,1) = 0.1*Irr(r,c,1) / (1 + 0.1*Irr(r,c,1));
        finalImg_01 (r,c,2) = 0.1*Irr(r,c,2) / (1 + 0.1*Irr(r,c,2));
        finalImg_01 (r,c,3) = 0.1*Irr(r,c,3) / (1 + 0.1*Irr(r,c,3));
        
        finalImg_05 (r,c,1) = 0.5*Irr(r,c,1) / (1 + 0.5*Irr(r,c,1));
        finalImg_05 (r,c,2) = 0.5*Irr(r,c,2) / (1 + 0.5*Irr(r,c,2));
        finalImg_05 (r,c,3) = 0.5*Irr(r,c,3) / (1 + 0.5*Irr(r,c,3));
        
        finalImg (r,c,1) = Irr(r,c,1) / (1 + Irr(r,c,1));
        finalImg (r,c,2) = Irr(r,c,2) / (1 + Irr(r,c,2));
        finalImg (r,c,3) = Irr(r,c,3) / (1 + Irr(r,c,3));
        
    end
end

imwrite(finalImg_005,'0chapel_005.png')
imwrite(finalImg_001,'0chapel_001.png')
imwrite(finalImg_01,'0chapel_01.png')
imwrite(finalImg_05,'0chapel_05.png')
imwrite(finalImg,'0chapel.png')


% Tonemap the image using MATLAB's local operator

local = localtonemap(single(Irr), 'RangeCompression', 0);
imwrite(local,'0chapel_local.png');

function w = triangle(z)
    z_min = 0;
    z_max = 255;
    if ( z <= (z_min + z_max)/2)
        w = z - z_min;
    else
        w = z_max - z ; 
    end
end
