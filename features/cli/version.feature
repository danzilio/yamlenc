Feature: cli/version
  Enc should print the version number at the command line

  Scenario: Passing the -v parameter at the command line should print the version number
    When I run `enc -v`
    Then the exit status should be 0
    Then the output should match /^(\d+)\.(\d+)\.(\d+)$/

  Scenario: Passing the --version parameter at the command line should print the version number
    When I run `enc --version`
    Then the exit status should be 0
    Then the output should match /^(\d+)\.(\d+)\.(\d+)$/
