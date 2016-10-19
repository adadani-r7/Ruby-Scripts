require 'nexpose'
include Nexpose

NexposeIP = 'ipaddress'
NexposeUN = 'username'
NexposePW = 'password'
NexposePORT = '443'

## Enter Credentials and IP for Nexpose connection
nsc = Connection.new(NexposeIP,NexposeUN,NexposePW,NexposePORT)

## Login to Nexpose
nsc.login

## Logout when the script exits
at_exit { nsc.logout }

asset_groups = [988,987] ## Insert Array of Group IDs

asset_groups.each do |group|
  
  ag = AssetGroup.load(nsc, group)  ## Insert Asset group ID
  puts ag
  devices = ag.devices
  while (devices.size > 0)
    asset_ids = []
    devices.first(5000).each { |a| asset_ids.push(a.id) }
    payload = asset_ids.to_json
  
    puts "Deleting assets..."
    current_time = Time.now()
    @resp = Nexpose::AJAX.post(nsc, '/data/assets/bulk-delete', payload, Nexpose::AJAX::CONTENT_TYPE::JSON)
    puts "Done deleting assets (seconds): " + (Time.now() - current_time).to_s 
	
	ag = AssetGroup.load(nsc, group)  ## Insert Asset group ID
    devices = ag.devices
  end
end