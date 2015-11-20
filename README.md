# YAML ENC

This is an external node classifier (ENC) for Puppet. This ENC reads from YAML
files and returns a node statement for Puppet to consume. There is a specific
schema for the YAML input.

# Basic example
Here's a basic example of a node file.

    ---
    node1.example.com:
      environment: production
      role: roles::puppet::master
      classes:
        - base::puppetmaster
      parameters:
        rack: R1
        elevation: 23
    node2.example.com:
      classes:
        - base::ntp
    ^(dc1|dc2)-host.example.com$:
      role: roles::puppet::puppetdb

# Node syntax reference
A node key can be a string literal or a regex pattern. All fields in a node
statement are optional.

- `environment` (string) - This is the Puppet environment that the node should run in.

- `role` (string) - This is the role class that should be included on the node. This class is automatically added to the node's `classes` section.

- `classes` (array of strings) - This is an array of classes to include on the node.

- `parameters` (hash of string keys and values) - This is a hash of parameters to pass to the node statements. Parameters must be strings and their values must also be strings.

# Configuration file
By default the command looks at `/etc/puppet/enc.yaml` for its configuration. You can override this by passing the `-c` or `--config` parameters at the command line. The configuration file only supports one configuration option at this time:

    ---
    nodes:
      - /etc/enc/nodes.yaml
      - /etc/enc/nodes2.yaml

The `nodes` option can be an array of strings or a single string. Each value must be a fully qualified path to node files. They will be parsed sequentially.

# Command line nodes
You can pass node files at the command line with the `-n` or `--nodes` option. The value must be a fully qualified path to a node file. These will be appended to the end of the `nodes` array and will be parsed in the order in which they're defined at the command line, after all of the nodes files defined in the configuration file.
