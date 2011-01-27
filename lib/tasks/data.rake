namespace :visa do
  desc "split file"
  task :load_data do
    Dir.glob("data/*.txt").each do | filename |
      dir = File.basename(filename).gsub(".txt","")
      puts "processing #{File.basename(filename)} ...."
      system `script/chop #{filename} #{dir}`
    end
  end
end
