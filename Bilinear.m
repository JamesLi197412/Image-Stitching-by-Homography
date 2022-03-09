function [intensity] = Bilinear(pointsR)

% imgR: image input
% new_image is interpolated intensity value

% dimension of img 
imgR = double(imread('right.jpg'));
row = size(pointsR,1);

intensity = zeros(1,row);

for i = 1:row
    x = pointsR(i,1);
    y = pointsR(i,2);
    
    x1 = floor(x);
    x2 = ceil(x);
    
    y1 = floor(y);
    y2 = ceil(y);

    temp = 1/((x2-x1)*(y2-y1));
    matrix_x = [x2-x,x-x1];
    matrix_img = [imgR(y1,x1), imgR(y2,x1);imgR(y1,x2), imgR(y2,x2)];
    matrix_y = [y2-y ; y-y1];
    
    intensity(i)= temp *matrix_x*matrix_img*matrix_y;


    fprintf('The intensity value is %4.2f\n',intensity(i));

end

end