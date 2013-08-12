
data = importdata('example_batch.csv',';',1);
[nb_row, ~] = size(data.data);

for j=1:nb_row, 
    try
        % get filenames
        input_path = data.textdata{j+1,1}
        output_path = data.textdata{j+1,2};

        % get parameters
        yaw_deg = data.data(j,1);
        pitch_deg = 8; %data.data(j,2);
        field_of_view_deg = 60; %data.data(j,3);
        output_size.width = 1000; %data.data(j,4); 
        output_size.height = 700; %data.data(j,5);

        % read the panoramic images
        pano_img = imread(input_path);

        % transform spherical coordinate and  cutout a perspective
        output_img = spher2pers(pano_img, yaw_deg, pitch_deg, field_of_view_deg, output_size);

        % save the perspective
        imwrite(output_img,output_path);
    catch err
        err
    end
end