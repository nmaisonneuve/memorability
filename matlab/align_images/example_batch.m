addpath('./jsonlab');

data = loadjson('example1.json');

nfiles = size(data,2);

for i=1:nfiles,
    ima = imread(data(i).imagepath);
    
    pts_a = data(i).from_pts;
    pts_b = data(i).to_pts;

    % to crop the output as the original size
    XData=[1 size(ima,2)];
    YData=[1 size(ima,1)];

    tform = maketform('affine',pts_a, pts_b);
    I2 = imtransform(ima,tform,'XData',XData,'YData',YData);
    
    % save the img
    imwrite(I2,data(i).outputpath);
end

