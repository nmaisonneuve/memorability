require "./lib/gsv_cutter.rb"

namespace :db do
	task :init do
		dbconfig = YAML::load(File.open('db/config.yml'))["development"]
		ActiveRecord::Base.establish_connection(dbconfig)
	end
end

desc "Generate CSV file of pairwises of GSV images from 2 time periods"
task :generate_listpairs  => ["db:init"] do
	require 'csv'

	# number of pairwises in the list
	# 0 = unlimited
	nb_pairwises = 0

	# geographical precision between old and new geographical images (distance in meters) 
	# 0 = perfect matching / same geocoordinates
	geo_precision = 0

	# we also minimise the yaw_def between the 2 images 
	# 'order by yaw_def difference' (smaller yaw_def difference = better)
	sql = 'SELECT new_panos."panoID" as new_panoID, new_panos.yaw_deg as new_yaw_deg, old_panos."panoID" as old_panoID,  old_panos.yaw_deg as old_yaw_deg, ST_ASTEXT(new_panos.latlng) as location '
	sql += ', abs(new_panos.yaw_deg - old_panos.yaw_deg) as diff '
	sql += ' FROM (SELECT * from panos where label is null) as new_panos'
	sql += ' inner JOIN (SELECT * from panos where label =1) as old_panos '
	sql += "ON ST_DWithin(new_panos.latlng,old_panos.latlng, #{geo_precision}) "
	sql += ' where new_panos."panoID" != old_panos."panoID"'
	sql += ' order by diff '
	sql += " limit #{nb_pairwises}" if nb_pairwises > 0

	results = ActiveRecord::Base.connection.select_rows(sql)
	puts "listing #{results.size} pairs"

	CSV.open("results/pairwises_paris.csv", "wb") do |csv|
		csv << ["recent_panoID", "old_panoID", "recent_yaw_deg" , "old_yaw_deg", "lat", "lng"]
		results.each do |row|
			recent_panoID = row[0]
			recent_yaw_deg = row[1]
			old_panoID = row[2]
			old_yaw_deg = row[3]
			lng,lat = /POINT\(([\d|\.]+) ([\d|\.]+)\)/.match(row[4])[1..2]
			csv << [ recent_panoID, old_panoID, recent_yaw_deg, old_yaw_deg , lat, lng]
		end
	end
end

desc "import metadata of the old paris GSV images"
task :import_old_data => ["db:init"]   do
	require 'csv'
	OLD_PANO = 1
	no_found = 0

	CSV.foreach("../data/old_data_paris/paris.csv") do |row|
		
		# renaming rows for clarity
		panoID = row[0]
		lat = row[1].to_f
		lng = row[2].to_f
		yaw_deg = row[3].to_f

		# creating a panoramic images if not existing
		pano = Pano.find_by_panoID(panoID)
		if pano.nil?
			# debug
			puts "pano #{panoID} not found (#{no_found})" if (no_found % 100) == 0

			# we create a new panorama
			Pano.create(
				panoID: panoID,
				latlng: "POINT (#{lng} #{lat})",
				label: OLD_PANO,
				yaw_deg: yaw_deg)

			no_found += 1
		else
			# we just update the yaw_deg attribute if not assigned yet
			pano.update_attributes(yaw_deg: yaw_deg) if pano.yaw_deg.nil?
			pano.update_attributes(label: OLD_PANO)
		end
	end
end

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

desc "Linking each pairwise dirs to images from data/ dir "
task :linking_pairwises do
	require "subexec"
	require 'csv'
	i = 0 
	Subexec.run "rm -Rf results/pairwises", :timeout => 0
	CSV.foreach("results/pairwises_paris.csv", headers: true) do |row|
		new_panoID = row[0]
		old_panoID = row[1]
		localdir = "../data/memorability/paris/#{row[2]}_#{row[3]}"
		new_filepath = "~/work/memorability/data/paris/#{new_panoID}_zoom_4.jpg"
		old_filepath = "~/work/memorability/data/old_paris/#{old_panoID}.jpg"

 		Subexec.run "mkdir -p results/pairwises/#{i}", :timeout => 0
 		cmd = "ln -s #{new_filepath} ~/work/memorability/results/pairwises/#{i}/#{new_panoID}.jpg"
 		Subexec.run cmd, :timeout => 0
 		Subexec.run "ln -s #{old_filepath} ~/work/memorability/results/pairwises/#{i}/#{old_panoID}.jpg", :timeout => 0
 		i += 1
	end
end

desc "Transform panoramic images into a set of perspectives"
task :cutout_pairwises do
	require "subexec"
	require 'csv'
	i = 0

	CSV.foreach("results/pairwises_paris.csv", headers: true) do |row|
		new_panoID = row[0]
		old_panoID = row[1]
		
		new_filepath = "~/work/memorability/data/paris/#{new_panoID}_zoom_4.jpg"
		old_filepath = "~/work/memorability/data/old_paris/#{old_panoID}.jpg"
 		
 		i += 1
		# WARNING: may not overwrite previous file
		# new_filepath_cutted = "#{localdir}/cutted_#{new_panoID}.jpg"
		# old_filepath_cutted = "#{localdir}/cutted_old_#{old_panoID}.jpg"
		cmd = "octave matlab/cutter.m '#{new_filepath}' '#{new_filepath_cutted}'"
 		puts cmd
 		Subexec.run cmd, :timeout => 0
 		
 		cmd = "octave matlab/cutter.m '#{old_filepath}' '#{old_filepath_cutted}'"
 		Subexec.run cmd, :timeout => 0
 		
 		puts " old image #{old_filepath} to #{old_filepath_cutted}"
	 	end
end
