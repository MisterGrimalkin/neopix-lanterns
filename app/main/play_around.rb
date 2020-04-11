require_relative 'fire_in_the_lantern'

include FireInTheLantern

def layers
  max_width = 0
  scn.layers.each do |key, _|
    max_width = [max_width, key.to_s.length].max
  end
  scn.layers.each do |key, layer|
    puts "#{key.to_s.ljust(max_width)} : #{layer.inspect}"
  end
  nil
end

def scenes
  scene = pick_from(
      Dir.glob("#{px.scenes_dir}/*.json").collect do |filename|
        filename.split('/')[-1].gsub('.json', '')
      end
  )
  px.load_scene scene if scene
end

if (options = ENV['OPTIONS'])
  if options.include?('-init')
    px.start
    puts "   px = #{px.inspect}\n\n"
  end
end