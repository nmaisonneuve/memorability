desc "Generate config file for cutting new panoramic images into perspectives"
task :cutout_new do
	require 'csv'
	config_file = "./results/batch_cutting_old_images.csv"
	parameters = {
		yaw_deg: 0, # side angle (0=front side , 180=back side, 90=left side, 270=right side)
	 	pitch_deg: 8,
	 	field_of_view_deg: 90,
	 	output_width: 500,
	 	output_height: 1500,
	}
	# collect the panoIDs
	inputs = []
	outputs = []
 	CSV.read("./results/pairwises_paris.csv", {headers: true}).each_with_index do |row, i|
		inputs << "~/work/memorability/data/paris/#{row[0]}_zoom_4.jpg" 
		outputs << 	"~/work/memorability/results/pairwises/p_#{i}_front_new_#{row[0]}.jpg"
	end
	generate_config_file(config_file, inputs, outputs, parameters)
end

desc "Generate config file for cutting old panoramic images into perspectives"
task :cutout_old do
	require 'csv'
	
	config_file = "./matlab/cut_images/batch_cutting_old_images.csv"
	parameters = {
		yaw_deg: 0,
	 	pitch_deg: 8,
	 	field_of_view_deg: 90,
	 	output_width: 100,
	 	output_height: 500,
	}
	inputs = []
	outputs = []
 	CSV.read("./results/pairwises_paris.csv", {headers: true}).each_with_index do |row, i|
		inputs << "~/work/memorability/data/old_paris/#{row[1]}.jpg" 
		outputs << 	"~/work/memorability/results/pairwises/p_#{i}_front_old_#{row[1]}.jpg"
	end
	generate_config_file(config_file, inputs, outputs, parameters)
end

def generate_config_file(config_filename, inputs, outputs, parameters)
	CSV.open(config_filename, "wb", {:col_sep => ";"}) do |csv|
		csv << ["input","output", "yaw_deg", "pitch_deg","field_of_view_deg", "output_width","output_height"]
		inputs.each_with_index do |input,i|
			csv << [	
			 	input,
			 	outputs[i],
			 	parameters[:yaw_deg],
			 	parameters[:pitch_deg],
			 	parameters[:field_of_view_deg],
			 	parameters[:output_width],
			 	parameters[:output_height]
	 		]
	 	end
	end
end


def run_config(config_path)
	require 'Subexec'
	matlab_cmd = "matlab -nodesktop -nosplash -r 'batch(\'#{config_path}\')'"
 #	Subexec.run cmd, :timeout => 0
end