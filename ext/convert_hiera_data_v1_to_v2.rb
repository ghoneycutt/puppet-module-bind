# This script is meant to take existing Hiera data in YAML format of
# bind::zones from v1 of this bind module and convert it to v2 of this module.
# In v2 bind::zone dropped the 'tag' parameter and instead encodes the tag into
# the name. Please see the README.md for more details.
#
# usage: ruby convert_hiera_data_v1_to_v2.rb path/to/data.yaml
#
# install dependencies: `gem install -V facets`
#
require 'facets'
require 'yaml'

yaml = YAML.load_file(ARGV[0])

zones = yaml['bind::zones']

h = { 'bind::zones' => {}}
zones.each do |k,v|
  if v.key?('tag')
    tag = v['tag']
    h['bind::zones']["#{k}:#{tag}"] = v.except('tag')
  else
    h['bind::zones'][k] = v
  end
end

puts h.to_yaml
