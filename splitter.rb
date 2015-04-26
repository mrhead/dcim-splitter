#!/usr/bin/env ruby

require 'fileutils'

class DirSplitter
  attr_reader :input_directory, :output_directory_base

  def initialize(input_directory, output_directory_base)
    @input_directory = input_directory
    @output_directory_base = output_directory_base
  end

  def split_dcim_files
    Dir.glob("#{input_directory}/**/*").each do |file|
      split_file(file) if File.file?(file)
    end
  end

  private

  def split_file(file)
    print "Processing #{file}... "
    output_directory = "#{output_directory_base}/#{file}"

    splitter = Splitter.new(file, output_directory)

    if splitter.has_dcim_files?
      if File.directory?(output_directory)
        puts "skipped because #{output_directory} already exists."
      else
        FileUtils.mkdir_p(output_directory)

        splitter.split_to_files
        puts 'done.'
      end
    else
      puts "skipped because it doesn't contains dcim files."
    end
  end

  def is_dcim?(file)
    DcimChecker.new(file).is_dcim?
  end
end

class Splitter
  SEPARATOR = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00DICM\x02\x00"

  attr_reader :file_in_string, :output_dir

  def initialize(file, output_dir = nil)
    @file_in_string = File.binread(file)
    @output_dir = output_dir || File.basename(file)
  end

  def split_to_files
    file_parts.each_with_index do |file_part, index|
      f = File.new("#{output_dir}/file_#{index}.dcm", 'w')
      file_content = SEPARATOR + file_part
      f.write(file_content)
      f.close
    end
  end

  def has_dcim_files?
    file_parts.size > 0
  end

  def file_parts
    @_file_parts ||= file_in_string.split(SEPARATOR).drop(1)
  end
end

if ARGV.size == 2
  DirSplitter.new(ARGV[0], ARGV[1]).split_dcim_files
else
  puts "Usage: ./splitter.rb <input_directory> <output_directory>"
end
