require 'nexpose'
include Nexpose

nsc = Connection.new('localhost','username','password')

begin
  nsc.login
rescue
end

if nsc.session_id
  puts "Login Successful"
else
  puts "Login Failure"
end

sites = nsc.list_sites
if sites.length == 0
  puts "No sites assigned to this user"
else
  sites.each do |site|
    puts "SiteID: #{site.id}"
    puts "Site Name: #{site.name}"
    site = Site.load(nsc,site.id)
    puts 'Starting scan'
    scan = nsc.scan_site(site.id)
  end
end

nsc.logout
