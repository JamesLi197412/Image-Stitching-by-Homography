

% ECE4076 Lab 3 
% Written by : Zhiyue Li
clear all;close all;clc

% Load the images
imgL = imread('left.jpg');
imgR = imread('right.jpg');

szIm = size(imgL);
szImR = size(imgR);

% Task 1: Draw test points on left image.
pointsL = [338,197,1;468,290,1;253,170,1;263,256,1;242,136,1];
RGB_L = insertMarker(imgL,[147,279]);
color = {'red','white','green','magenta','red'};
imgL_marked = insertMarker(RGB_L,pointsL(:,1:2),'x','color',color,'size',10);
figure();
imshow(imgL_marked); 
title('Left image with markers');


% Task 2: Use Homography to find right image points
H =[1.6010 -0.0300 -317.9341;0.1279 1.5325 -22.5847;0.0007 0 1.2865];

pointsR = zeros(size(pointsL));

for i = 1:length(pointsL(:,2,:))
    pointsR(i,:) = H*pointsL(i,:)';
    pointsR(i,:) = pointsR(i,:)./pointsR(i,3);
end


RGB_R = insertMarker(imgL,[147 279]);
imgR_marked = insertMarker(RGB_R,pointsR(:,1:2),'x','color',color,'size',10);
figure();  
imshow(imgR_marked); 
title('Right image with marks labeled');

% Task 3: Bilinear interpolation of the right image
% Calculate the interpolated intensity value
[intensity] = Bilinear(pointsR(:,1:2));



% Task 4: Image stitching 
stitch_image = zeros(384,1024);
left_image = im2double(imread('left.jpg'));
stitch_image(1:384,1:512) = left_image;
stitch_coordinate = zeros(3,1);
imgR_double = im2double(imread('right.jpg'));

for i = 1:384
    for j = 512:1024
        stitch_coordinate = H*[j+1,i,1]';
        stitch_coordinate = stitch_coordinate/stitch_coordinate(3); % 
        stitch_coordinate = stitch_coordinate(1:2);
        if ((stitch_coordinate(1) <= 512 && stitch_coordinate(1)>=1) && (stitch_coordinate(2)<=384 && stitch_coordinate(2)>=1))
            x = stitch_coordinate(1);
            y = stitch_coordinate(2);
            
            x1 = floor(x);
            x2 = ceil(x);

            y1 = floor(y);
            y2 = ceil(y);

            temp = 1/((x2-x1)*(y2-y1));
            matrix_x = [x2-x,x-x1];
            matrix_img = [imgR_double(y1,x1), imgR_double(y2,x1);imgR_double(y1,x2), imgR_double(y2,x2)];
            matrix_y = [y2-y ; y-y1];

            stitch_image(i,j)= temp *matrix_x*matrix_img*matrix_y;
        else
            stitch_image(i,j) = 0;
        end
    end
end

% stitch_image(:,1:512) = imgL;

% find out the black pixels
for i = 512:1024
    if (stitch_image(:,i) == 0)
        i
        break
    end
end

figure(3);
imshow(stitch_image(:,1:795)); 
title('Stitch image');

% Task 5: Better blending
% adjust the brightness of each image so that the seam is less visible
% adjust the width of image
% Find out the mean value for each image and got factor
mean_L = mean(imgL);
mean_R = mean(imgR);
factor = mean_L / mean_R;

% Assuemd that seam point is the midpoint between the first overlap column
%
firstOverlap = find(pointsR(:,1)>1,1);
seamEstimated = round((firstOverlap + 1.15*szIm(2))/2);

stitch_image_improved = zeros(384,1024);
left_image = im2double(imread('left.jpg'));
stitch_image_improved(1:384,1:512) = left_image;
stitch_coordinate = zeros(3,1);
imgR_double = im2double(imread('right.jpg'));
imgR_double = imgR_double/(factor*1.25);

for i = 1:384
    for j = 512:1024
        stitch_coordinate = H*[j+1,i,1]';
        stitch_coordinate = stitch_coordinate/stitch_coordinate(3); % 
        stitch_coordinate = stitch_coordinate(1:2);
        if ((stitch_coordinate(1) <= 512 && stitch_coordinate(1)>=1) && (stitch_coordinate(2)<=384 && stitch_coordinate(2)>=1))
            x = stitch_coordinate(1);
            y = stitch_coordinate(2);
            
            x1 = floor(x);
            x2 = ceil(x);

            y1 = floor(y);
            y2 = ceil(y);

            temp = 1/((x2-x1)*(y2-y1));
            matrix_x = [x2-x,x-x1];
            matrix_img = [imgR_double(y1,x1), imgR_double(y2,x1);imgR_double(y1,x2), imgR_double(y2,x2)];
            matrix_y = [y2-y ; y-y1];

            stitch_image_improved(i,j)= temp *matrix_x*matrix_img*matrix_y;
        else
            stitch_image_improved(i,j) = 0;
        end
    end
end

figure(4);
imshow(stitch_image_improved(:,1:795)); 
title('Improved Stitch image');







