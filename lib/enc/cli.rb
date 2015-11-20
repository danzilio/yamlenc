require 'yaml'
require 'optparse'

module Enc
  class Cli
    attr_accessor :options
    attr_reader :node_name, :found

    def initialize(argv)
      @options = { config_file: '/etc/puppet/enc.yaml', cli_nodes: [], fail: false }

      optparse.parse!(argv)

      if (@node_name = argv[0]).nil?
        puts "ERROR: Didn't specify a node name to look up!"
        puts ''
        puts optparse.to_s
        exit 1
      end

      @found = find
    end

    private

    def find
      Node.lookup(node_name, nodes) unless nodes.empty?
    end

    def optparse
      OptionParser.new do |opt|
        opt.banner = "Usage: #{$PROGRAM_NAME} <options> <hostname>"
        opt.separator ''
        opt.separator 'Available options:'
        opt.on('-c', '--config [path to configuration file]', String, 'Path to configuration file (Default: /etc/puppet/enc.yaml).') { |c| options[:config_file] = c if c }
        opt.on('-n', '--nodes [path to data file]', String, 'Path to a data file to add to the end of the "nodes" array') { |n| options[:cli_nodes] << n if n }
        opt.on('-f', '--fail', 'Fail if no nodes are found.') { |f| options[:fail] = f }
        opt.on('-v', '--version', 'Print the version') do
          puts Enc::VERSION
          exit 0
        end
        opt.on_tail('-h', '--help', 'Show this message') do
          puts opt
          exit 0
        end
      end
    end

    def config_file
      options[:config_file]
    end

    def collect_nodes(nodes)
      collection = []

      nodes.each do |node|
        collection << node if File.file?(node)
        collection += Dir["#{node}/*.yaml"].sort if File.directory?(node)
      end

      collection
    end

    def cli_nodes
      return [] if options[:cli_nodes].empty?
      collect_nodes(options[:cli_nodes])
    end

    def config
      return {} unless File.exist?(config_file)
      Hash(YAML.load_file(config_file))
    end

    def config_nodes
      return [] unless config.include?('nodes')
      collect_nodes(Array(config['nodes']))
    end

    def nodes
      fail('No node files specified!') if config['nodes'].nil? && cli_nodes.empty?

      cli_nodes + config_nodes
    end
  end
end
