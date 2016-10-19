require 'csv'              #  Import from CSV
require 'logger'           #  Debug logging
gem 'nexpose', '>0.5'      #  Installs Nexpose gem
require 'nexpose'          #  Required for Nexpose
require 'yaml'             #  Used for importing Nexpose credentials
include Nexpose            #  Used instead of absolute path to gem

## Enable Logging so that all Site Creation and Modification are tracked
log = Logger.new(STDOUT)
log.level = Logger::DEBUG

## Variables to Configure
$settings = YAML::load_file 'settings.yml'
NexposeIP = $settings[:nexpose][:host]
NexposeUN = $settings[:nexpose][:user]
NexposePW = $settings[:nexpose][:pass]

nsc = Connection.new(NexposeIP, NexposeUN, NexposePW)
nsc.login
at_exit { nsc.logout }

 # Set the SMTP Sender Address
sender = 'test@company.com'
 # Set the SMTP Relay Server
server = 'relay.company.com'

 # Any severity: 1
 # Severe and critical: 4
 # Only critical: 8

## Data structure to describe imported site data from CSV
class SiteInfo
    attr_accessor :name, :alert_name, :sev, :recipients, :scan_events
  def initialize(name)
    @name = name
    @alert_name = []
    @sev = []
    @recipients = []
    @scan_events = []
  end
end

## Create a hash of sites to import to Nexpose
sites_to_import = {}

## Parse through CSV to populate the hash that was created in the previous step
CSV.foreach('site_alerts.csv', {:headers => true, :encoding => "ISO-8859-15:UTF-8"}) do |row|
  ##puts row
  name = row['Site Name']
  site = sites_to_import[name]
  if site.nil?
    log.debug "Site '#{name}' found in CSV file"
    #puts "Site #{name} found in CSV file"
    site = SiteInfo.new(name)
    sites_to_import[name] = site
  end
  site.alert_name << row['Alert Name'] if row['Alert Name']
  site.sev << row['Severity'] if row['Severity']
  site.recipients << row['Recipients'] if row['Recipients']
  site.scan_events << row['Scan Events'] if row['Scan Events']
end

#Pull currrent Site info from Nexpose
site_listing = nsc.list_sites

sites_to_import.each do |site_import|
  site_import = site_import[1]
  begin
    ## if site exists, load it
    site = site_listing.select {|site_summary| site_summary.name == site_import.name}
    log.debug "Checking if site exists - #{site_import.name} - #{site}"
    begin
      log.debug "#{site_import.name} found"
      site = Site.load(nsc, (site[0].id))
    rescue
      log.debug "#{site_import.name} not found"
      exit 1
    end
      #### Setting the Alert ####

         #Alert input: name, alert_type, enabled
    if site_import.alert_name.to_s != ""
      a_name = site_import.alert_name
      alen = a_name.length
      (0..alen-1).each do |i|
        smtp_alert = SMTPAlert.new(a_name[i], sender, server, site_import.recipients[i].split(','), max_alerts = -1)
        scanEvent = ScanFilter.new(start = site_import.scan_events[i].split(',')[0], stop = site_import.scan_events[i].split(',')[1], fail = site_import.scan_events[i].split(',')[2], pause = site_import.scan_events[i].split(',')[3], resume = site_import.scan_events[i].split(',')[4])
        vulnEvent = VulnFilter.new(severity = site_import.sev[i], confirmed = 0, unconfirmed = 0, potential = 0)
        smtp_alert.scan_filter = scanEvent
        smtp_alert.vuln_filter = vulnEvent
        site.alerts << smtp_alert
      end
    end

         ## save the site configuration
    begin
      retries = [3,5,10]

      site.save(nsc)
      log.info "Saved site #{site.name} (id:#{site.id})"

        ## try to recover if we encounter network problems
    rescue Timeout::Error, Errno::ECONNRESET, Errno::ETIMEDOUT => e
      log.error e
      if delay = retries.shift
        sleep delay
        log.warn "Retrying... - #{site_import.name}"
        retry
      else
        log.warn "Retry attempts exceeded, moving on to the next site - #{site_import.name}"
      end
    end
  ## log Nexpose API errors and move on
  rescue Nexpose::APIError => e
    ## if you hit ctrl+c, exit instead of resuming
    if e.to_s.include? "Received a user interrupt"
      log.warn "Exit requested by user"
      exit(0)
    end
    log.error "#{e.message} in site #{site_import.name}"

  end
end
