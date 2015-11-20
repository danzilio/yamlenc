Feature: node
  Enc needs to return a node statement in the correct format or exit 1

  Scenario: Finding a node that explicitly matches
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
    And the output should match:
    """
    parameters:\s*role: puppet/puppetdb
    """

  Scenario: Finding a node that matches a regex
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
    When I run `enc -n nodes.yaml dc1-puppet01`
    Then the exit status should be 0
    Then the output should match /environment: production/
    And the output should match /classes:\s*- roles::puppet::master/
    And the output should match:
    """
    parameters:\s*role: puppet/master
    """

  Scenario: Trying to find a nonexistent node
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
    When I run `enc -n nodes.yaml dc1-server09`
    Then the exit status should be 0
    And the output should contain exactly "{}\n"

  Scenario: Trying to find a nonexistent node with failing enabled
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
    When I run `enc -f -n nodes.yaml dc1-server09`
    Then the exit status should be 1
    Then the output should contain:
    """
    No node found.
    """

  Scenario: Finding a node that explicitly matches multiple files
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
    When I run `enc -n nodes.yaml -n nodes2.yaml dc4-server01`
    Then the exit status should be 0
    Then the output should match /classes:\s*- base/

  Scenario: Finding a node that explicitly matches one file
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

  Scenario: Finding a node with the role in 'role' and 'classes' should deduplicate the 'classes' array
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
        - roles::puppet::puppetdb
    """
    When I run `enc -n nodes.yaml dc1-puppetdb01`
    Then the exit status should be 0
    Then the output should match /classes:\s*- base\s*- ntp\s*- roles::puppet::puppetdb/
    And the output should match /environment: stage/
    And the output should match:
    """
    parameters:\s*role: puppet/puppetdb
    """

  Scenario: When giving a directory of node files to the ENC
    Given a directory named "nodes"
    And a file named "nodes/1_nodes.yaml" with:
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
    And a file named "nodes/2_nodes.yaml" with:
    """
    ---
    dc4-www01:
      classes:
        - apache
    """
    When I run `enc -n nodes dc4-server01`
    Then the exit status should be 0
    Then the output should match /classes:\s*- base/

  Scenario: When giving the enc a node file that does not exist
    Given a file named "enc.yaml" with:
    """
    ---
    nodes:
      - /tmp/aruba/nodes/nodes.yaml
    """
    And a directory named "nodes"
    And a file named "nodes/node.yaml" with:
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
    When I run `enc -c enc.yaml dc4-server03`
    Then the exit status should be 0
    And the output should contain exactly "{}\n"

  Scenario: When giving the enc a node file that does not exist with failing enabled
    Given a file named "enc.yaml" with:
    """
    ---
    nodes:
      - /tmp/aruba/nodes/nodes.yaml
    """
    And a directory named "nodes"
    And a file named "nodes/node.yaml" with:
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
    When I run `enc -f -c enc.yaml dc4-server03`
    Then the exit status should be 1
    Then the output should contain:
    """
    No node found.
    """
