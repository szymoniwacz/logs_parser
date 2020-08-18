#!/usr/bin/env ruby
# frozen_string_literal: true

class Parser
  attr_accessor :errors, :file, :logs

  def initialize
    @logs = []
    @errors = []
  end

  def parse
    read_file
    initiate_logs

    return puts @errors if @errors.any?

    parse_logs
  end

  def read_file
    @file = File.open(ARGV.first)
  rescue StandardError
    @errors << 'Incorrect file name or file does not exist.'
  end

  def initiate_logs
    return if @file.nil?

    # Groups log file lines by the path and assign an array of client's IP addresses.
    @logs = @file.readlines.group_by { |line| line.split(' ')[0] }.map do |path, ips|
      [path, ips.map { |ip| ip.split(' ')[1] }]
    end
    @errors << 'Log file is empty.' if @logs.empty?
  end

  def parse_logs
    parse_views
    parse_unique_views
  end

  def parse_views
    puts 'Visits:'
    @logs.sort_by { |log| -log[1].length }.each do |log|
      counter = log[1].length
      puts "#{log[0]} #{counter} #{counter == 1 ? 'visit' : 'visits'}"
    end
  end

  def parse_unique_views
    puts 'Unique views:'
    @logs.sort_by { |log| -log[1].uniq.length }.each do |log|
      counter = log[1].uniq.length
      puts "#{log[0]} #{counter} unique #{counter == 1 ? 'view' : 'views'}"
    end
  end
end

Parser.new.parse
