#!/usr/bin/env ruby

class DirSplitter
  attr_reader :directory
  def initialize(directory)
    @directory = directory
  end

  def split_dcim_files
    Dir["#{directory}/*"].each do |file|
      split_file(file) if File.file?(file)
    end
  end

  private

  def split_file(file)
    print "Processing #{file}... "
    output_directory = "#{file}_output"

    if File.directory?(output_directory)
      puts "skipped because #{output_directory} already exists."
      next
    else
      Dir.mkdir(output_directory)
    end

    Splitter.new(file, output_directory).split_to_files
    puts "done."
  end
end

class Splitter
  SEPARATOR = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00DICM\x02\x00"

  attr_reader :file_in_string

  def initialize(file, output_dir = nil)
    @file_in_string = File.binread(file)
    @output_dir = output_dir || File.basename(file)
  end

  def split_to_files
    file_parts.each_with_index do |file_part, index|
      f = File.new("#{output_dir}/file_#{index}", 'w')
      file_content = SEPARATOR + file_part
      f.write(file_content)
      f.close
    end
  end

  def file_parts
    file_in_string.split(SEPARATOR)
  end
end

if ARGV.size == 1
  DirSplitter.new(ARGV[0]).split_dcim_files
else
  puts "Usage: ./splitter.rb <directory>"
end
