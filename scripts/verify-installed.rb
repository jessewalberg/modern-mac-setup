#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

root = File.expand_path("..", __dir__)
packages = YAML.safe_load(
  File.read(File.join(root, "config", "packages.yml")),
  permitted_classes: [],
  aliases: false
).fetch("packages")

selected_groups = ARGV.empty? ? %w[foundation cli] : ARGV
errors = []

packages.select { |package| selected_groups.include?(package.fetch("group")) }.each do |package|
  next unless package["command"]

  command = package.fetch("command")
  found = ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? do |directory|
    path = File.join(directory, command)
    File.file?(path) && File.executable?(path)
  end
  errors << "#{package.fetch('token')} installed but expected command '#{command}' was not found" unless found
end

if errors.empty?
  puts "Expected commands are installed for groups: #{selected_groups.join(', ')}"
  exit 0
end

warn errors.map { |error| "ERROR: #{error}" }.join("\n")
exit 1
