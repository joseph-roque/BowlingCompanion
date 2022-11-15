# frozen_string_literal: true

require_relative './dependency'

module External
  def self.fetch_exports(package_yaml)
    exports = {}
    package_yaml['package']['dependencies'].flat_map do |d|
      d['exports'].map do |e|
        exports[e] = Export.new(name: e, package: d['url'][%r{https://github\.com/.*?/(.*)\.git}, 1])
        exports[exports[e].name] = exports[e]
      end
    end
    exports
  end

  def self.fetch_packages(package_yaml)
    packages = {}
    package_yaml['package']['dependencies'].each do |d|
      name = d['url'][%r{https://github\.com/.*?/(.*)\.git}, 1]
      packages[name] = Package.new(url: d['url'], from: d['from'])
    end

    packages
  end

  class Package
    attr_reader :url, :from

    def initialize(url:, from:)
      @url = url
      @from = from
    end
  end

  class Export < Dependency::Dependency
    attr_reader :name

    def initialize(name:, package:)
      @name = ".product(name: \"#{name}\", package: \"#{package}\")"
    end

    def external?
      true
    end

    def interface
      nil
    end
  end
end
