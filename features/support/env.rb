require 'aruba/cucumber'
require 'fileutils'

Before do
  FileUtils.rm_rf('/tmp/aruba')
  @dirs = ['/tmp/aruba']
end
