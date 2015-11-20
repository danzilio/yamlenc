require 'enc'

def fixture(path)
  File.expand_path(File.join(__FILE__, '..', 'fixtures', path))
end

RSpec.configure do |c|
  c.formatter = 'documentation'
  c.color = true
end
