#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

require "open3"
require "yaml"

root = File.expand_path("..", __dir__)
packages = YAML.safe_load(
  File.read(File.join(root, "config", "packages.yml"), encoding: "UTF-8"),
  permitted_classes: [],
  aliases: false
).fetch("packages")

selected_groups = ARGV.empty? ? %w[foundation cli] : ARGV
errors = []
verified = []

packages.select { |package| selected_groups.include?(package.fetch("group")) }.each do |package|
  next unless package["command"]

  command = package.fetch("command")
  path = nil
  ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).each do |directory|
    candidate = File.join(directory, command)
    if File.file?(candidate) && File.executable?(candidate)
      path = candidate
      break
    end
  end

  unless path
    errors << "#{package.fetch('token')} installed but expected command '#{command}' was not found"
    next
  end

  stdout, stderr, status = Open3.capture3(path, "--version")
  first_line = (stdout.empty? ? stderr : stdout).lines.first.to_s.strip
  unless status.success?
    errors << "#{command} exists at #{path} but --version failed: #{first_line}"
    next
  end

  verified << "#{command}: #{first_line} (#{path})"
end

if errors.empty?
  puts "Expected commands work for groups: #{selected_groups.join(', ')}"
  verified.each { |line| puts "  #{line}" }
  exit 0
end

warn errors.map { |error| "ERROR: #{error}" }.join("\n")
exit 1
