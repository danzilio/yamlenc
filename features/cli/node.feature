Feature: cli/node
  Enc needs to be able to accept node data at the command line

  Scenario: Passing a node file at the command line with a nonexistent config file
    Given a file named "nodes.yaml" with:
    """
    ---
    ^(dc1|dc2)-puppet01$:
      environment: production
      role: roles::puppet::master
    dc1-puppetdb01:
      environment: stage
      role: roles::puppet::puppetdb
      classes:
        - base
        - ntp
    dc4-server01:
      classes:
        - base
    dc4-server02:
      parameters:
        param: value
    """
    When I run `enc -n nodes.yaml dc1-puppetdb01`
    Then the exit status should be 0
    Then the output should match /classes:\s*- base\s*- ntp\s*- roles::puppet::puppetdb/
    And the output should match /environment: stage/
    And the output should match:
    """
    parameters:\s*role: puppet/puppetdb
    """

  Scenario: Passing multiple node files at the command line with no config file
    Given a file named "nodes.yaml" with:
    """
    ---
    ^(dc1|dc2)-puppet01$:
      environment: production
      role: roles::puppet::master
    dc1-puppetdb01:
      environment: stage
      role: roles::puppet::puppetdb
      classes:
        - base
        - ntp
    dc4-server01:
      classes:
        - base
    dc4-server02:
      parameters:
        param: value
    """
    And a file named "nodes2.yaml" with:
    """
    ---
    dc4-www01:
      classes:
        - apache
    """
    When I run `enc -n nodes.yaml -n nodes2.yaml dc4-www01`
    Then the exit status should be 0
    Then the output should match /classes:\s*- apache/

  Scenario: Passing multiple node files at the command line with a nonexistent config file
    Given a file named "nodes.yaml" with:
    """
    ---
    ^(dc1|dc2)-puppet01$:
      environment: production
      role: roles::puppet::master
    dc1-puppetdb01:
      environment: stage
      role: roles::puppet::puppetdb
      classes:
        - base
        - ntp
    dc4-server01:
      classes:
        - base
    dc4-server02:
      parameters:
        param: value
    """
    And a file named "nodes2.yaml" with:
    """
    ---
    dc4-www01:
      classes:
        - apache
    """
    When I run `enc -c nonexistent.yaml -n nodes.yaml -n nodes2.yaml dc4-www01`
    Then the exit status should be 0
    Then the output should match /classes:\s*- apache/

  Scenario: Passing an empty configuration file
    Given a file named "enc.yaml" with:
    """
    ---
    """
    When I run `enc -c enc.yaml dc4-www01`
    Then the exit status should be 1
    Then the output should match /No node files specified/

  Scenario: Passing an empty nodes directory
    Given a file named "enc.yaml" with:
    """
    ---
    nodes:
      - /tmp/aruba/nodes
    """
    Given a directory named "nodes"
    When I run `enc -c enc.yaml dc4-www01`
    Then the exit status should be 0
    And the output should contain exactly "{}\n"

  Scenario: Passing an empty nodes directory with failing enabled
    Given a file named "enc.yaml" with:
    """
    ---
    nodes: /tmp/aruba/nodes
    """
    And a directory named "nodes"
    When I run `enc -f -c enc.yaml dc4-www01`
    Then the exit status should be 1
    Then the output should match /No node found/

  Scenario: Not passing a node name
    Given a file named "enc.yaml" with:
    """
    ---
    nodes: /tmp/aruba/nodes.yaml
    """
    And a file named "nodes.yaml" with:
    """
    ---
    ^(dc1|dc2)-puppet01$:
      environment: production
      role: roles::puppet::master
    dc1-puppetdb01:
      environment: stage
      role: roles::puppet::puppetdb
      classes:
        - base
        - ntp
    dc4-server01:
      classes:
        - base
    dc4-server02:
      parameters:
        param: value
    """
    When I run `enc -c enc.yaml`
    Then the exit status should be 1
    Then the output should match /ERROR: Didn't specify a node name to look up!/
