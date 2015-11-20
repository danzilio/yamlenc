require 'yaml'

module Enc
  class Node
    attr_reader :node, :role, :environment

    def initialize(node)
      @node = node
      @role = validate('role', String)
      @environment = validate('environment', String)
      @classes = validate('classes', Array)
      @parameters = validate('parameters', Hash)
      @node_hash = to_hash
    end

    # Search through the files in the `nodes` array until we find one that
    # matches the node `name`. Set `@found` to the node hash returned by
    # `.search_nodes`.
    #
    # @api public
    # @param name [String] the name of the node to look for.
    # @param nodes [Array] an array of node files to search.
    def self.lookup(name, nodes)
      found = nil
      nodes.each do |c|
        found = search(name, YAML.load_file(c))
        break if found
      end
      Node.new(found) if found
    end

    # Return the hash version of the node statement in YAML
    #
    # @api public
    # @return [String] the YAML representation of the node statement
    def to_yaml
      to_hash.to_yaml unless to_hash.empty?
    end

    # Return the classes array. Checks if a role class has been delcared via
    # #role. If there's a role add it to the classes array.
    #
    # @api public
    # @return [Array, nil] the array of classes, or nil
    def classes
      if role
        return [role] unless @classes
        @classes << role unless @classes.include?(role)
      end

      @classes
    end

    # Return the parameters hash. Checks if a role class has been delcared via
    # #role. If there's a role, format it correctly (drop the 'roles' class,
    # change the class separator :: to / for filesystem use) add it to the
    # parameters hash as 'role' overriding anything else set there.
    #
    # @api public
    # @return [Hash, nil] the Hash of parameters, or nil
    def parameters
      if role
        role_parameter = role.gsub(/^roles::/, '').gsub(/::/, '/')
        @parameters = { 'role' => role_parameter } unless @parameters
        @parameters['role'] = role_parameter
      end

      @parameters
    end

    private

    # Takes a node name and hash of nodes and return the matching node statement
    # or nil if no node statement is found.
    #
    # @api private
    # @param name [String] a node name to search for.
    # @param nodes [Hash] a hash of node statements to search.
    # @return [Hash, nil] the matching node statement or nil if none is found.
    def self.search(name, nodes)
      nodes.keys.each do |k|
        return nodes[k] if name == k || name.match(k)
      end
      nil
    end

    # Takes a key name, and data type and ensures that the data in nodes[key] is
    # the correct data type. If it's not the correct data type, we'll fail and
    # print a message. If nodes[key] is the correct data type and is not empty,
    # return it, otherwise we return nil.
    #
    # @api private
    # @param key [String] a key name to search the nodes hash for
    # @param type [Object] a data type to check for
    # @return [Object, nil] returns the data of 'type' or nil if the value is empty
    def validate(key, type)
      return nil unless node && node.key?(key)
      fail "#{key.capitalize} must be a #{type}!" unless node[key].is_a?(type)
      return node[key] unless node[key].empty?
    end

    # A hash representation of the node statement
    #
    # @api private
    # @return [Hash] the node statment in Hash form
    def to_hash
      node_hash = {}
      node_hash['environment'] = environment if environment
      node_hash['classes'] = classes if classes
      node_hash['parameters'] = parameters if parameters
      node_hash
    end
  end
end
