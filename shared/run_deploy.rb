require 'rubygems'
#require 'action_mailer'
require 'json'

live_targets = ['live', 'quanzhou', 'baoshan']

deploy_to, target = ARGV
puts deploy_to

target = 'live' if live_targets.include? target

mapping = JSON.parse( File.read( "#{deploy_to}/current/shared/mapping.json" ) )

cmds = [] 
['global', target].each do|section|
  printf("linking '#{section}' ...\n")
  mapping[section].each do|source, target|
    [source, target].each {|v| v.gsub!('#{release_path}', deploy_to)}
    # it's dangous!
    cmds << "rm -rf #{target}"
    cmds << "ln -nfs #{source} #{target}"
  end if mapping[section]
end

puts "executing '#{cmds.join(' && ')}'" 

exec(cmds.join(' && '))
