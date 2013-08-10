
desc "Collecting gsv images of the current Paris"
task :collect_new_images  do
	require 'csv'
	require 'gsv_downloader'
	# for each pairwise, collect only the recent gsv images not existing locally
	i = 0
	queue = []
	CSV.foreach("results/pairwises_paris.csv", headers: true) do |row|
		new_panoID = row[0]
		localpath = "data/paris/#{new_panoID}_zoom_4.jpg"
		unless File.exists?("./"+localpath)
			puts "image #{i} not downloaded yet"	
			queue << {panoID: new_panoID, localpath: localpath}		
		end
		i += 1
	end

	# collect new gsv ones 
	puts "#{ queue.size} new images to download"
	downloader = ImageDownloaderParallel.new
	queue.each do |image|
		begin
		downloader.download(image[:panoID], 4,"./data/paris")
		p "image #{image[:panoID]} downloaded."
		rescue Exception => e
			p "Is #{image[:panoID]}  also obsolete?"
		end
	end
end

desc "collect gsv images of the old Paris (Petr's dataset)"
task :collect_old_images  do
	require 'net/scp'
	require 'csv'

	# build the idx of the old panoID in oder to retrieve them from /meleze
	filename_panoID = {}
	CSV.foreach("data/old_paris/old_paris_gsv.csv") do |row|
		filename_panoID[row[0]] = row[4]
	end
	puts "old paris data loaded."

	# for each pairwise, collect the old one 
	i = 0
	queue = []
	CSV.foreach("results/pairwises_paris.csv", headers: true) do |row|
		old_panoID = row[1]
		filename = filename_panoID[old_panoID]
		remotepath =  "/meleze/data1/maisonne/mnt/sterim/Work/Paris/wave/pano/#{filename}"
		localpath = "results/old_paris/#{old_panoID}.jpg"
		i += 1
		unless File.exists?("./"+localpath)
			queue << {remotepath: remotepath, localpath: localpath}
		end
	end

	# collect old ones using ssh
	puts "#{ queue.size} old images to download"
	sshconfig = YAML::load(File.open('config/ssh.yml'))["ssh"]
	Net::SCP.start("meleze", sshconfig["login"], :password => sshconfig["password"]) do |scp|
		queue.each do |image|
			begin
			d1 = scp.download(image[:remotepath], image[:localpath]) 
			d1.wait
			rescue Exception => e
				p e
			end
		end
	end
end