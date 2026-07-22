#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "uri"

ROOT = File.expand_path("..", __dir__)
CATALOG_PATH = File.join(ROOT, "config", "packages.yml")
FILES_BY_GROUP = {
  "foundation" => File.join(ROOT, "Brewfile"),
  "cli" => File.join(ROOT, "Brewfile.cli"),
  "apps" => File.join(ROOT, "Brewfile.apps.example")
}.freeze

errors = []
catalog = YAML.safe_load(File.read(CATALOG_PATH), permitted_classes: [], aliases: false)
packages = catalog.fetch("packages")

seen = {}
packages.each do |package|
  token = package.fetch("token")
  type = package.fetch("type")
  group = package.fetch("group")
  docs = package.fetch("docs")
  key = [type, token]

  errors << "duplicate catalog entry: #{type} #{token}" if seen[key]
  seen[key] = true

  errors << "invalid package type for #{token}: #{type}" unless %w[formula cask].include?(type)
  errors << "invalid package group for #{token}: #{group}" unless FILES_BY_GROUP.key?(group)
  errors << "#{token} must define command or app" unless package["command"] || package["app"]

  begin
    uri = URI.parse(docs)
    errors << "invalid docs URL for #{token}: #{docs}" unless uri.is_a?(URI::HTTP) && uri.host
  rescue URI::InvalidURIError
    errors << "invalid docs URL for #{token}: #{docs}"
  end

  declaration = type == "cask" ? %(cask "#{token}") : %(brew "#{token}")
  target = FILES_BY_GROUP.fetch(group)
  contents = File.read(target)
  errors << "missing #{declaration} in #{File.basename(target)}" unless contents.include?(declaration)
end

FILES_BY_GROUP.each_value do |path|
  File.foreach(path).with_index(1) do |line, line_number|
    next unless (match = line.match(/^\s*#?\s*(brew|cask)\s+"([^"]+)"/))

    type = match[1] == "brew" ? "formula" : "cask"
    token = match[2]
    errors << "uncataloged declaration in #{File.basename(path)}:#{line_number}: #{type} #{token}" unless seen[[type, token]]
  end
end

if errors.empty?
  puts "Package catalog is consistent with the Brewfiles."
  exit 0
end

warn errors.map { |error| "ERROR: #{error}" }.join("\n")
exit 1
