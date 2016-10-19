## Instructions:


## Step 1: Install Ruby 1.9.3 or higher (install method is dependant on platform)
## Step 2: Install the nexpose 0.5.4 gem from a command prompt(gem install -v 0.5.4 nexpose)
## Step 3: Edit the script and edit the line 'nsc = Nexpose::Connection.new('ConsoleIP', 'UserID', 'Password')' with your nexpose console IP address, username and password.
## Step 4: Edit the line 'CSV.foreach('VulnExceptions.csv', {:headers => true}) do |row|' to relect the name and location of your csv file.
## Step 5: Create a dynamic asset group filtering on assets with the vulnerabilities you wish to exclude.
## Step 6: Modify the CSV file to include the vulnerabilities you wish to exclude. You can copy and paste the
## complete or partial vulnerability name in the 'Vuln Exception Tag' column. If you use the partial name, be
## cautious, it could create an exception for unintended vulnerabilities. For example, placing 'ICMP' in the
## column will exclude all ICMP related vulnerabilities.
## Step 7: Execute the script 'ubuntu$ ruby bulk_exceptions_v2.rb'

## Other Relevent Info:

## Date format in the 'Expiration Date' column in the CSV must be MM/DD/YY

## Action Flag Key:
## C = CREATE a new exclusion
## D = DELETE an existing exclusion
## U = UPDATE and existing exclusion
## A = CREATE an exclusion for ALL vulnerabilities on ALL assets


require 'nexpose'
gem 'nexpose', '~> 0.9.8'
require 'time'
require 'csv'
require 'yaml'
require 'date'
require 'logger'
include Nexpose


## Enable Logging so that all Site Creation and Modification are tracked
log = Logger.new(STDOUT)
log.level = Logger::INFO

## Variables to Configure
$settings = YAML::load_file 'settings.yml'

NexposeIP = $settings[:nexpose][:host]
NexposeUN = $settings[:nexpose][:user]
NexposePW = $settings[:nexpose][:pass]

log_file = 'exceptions.log'

## Enter Credentials and IP for Nexpose connection
nsc = Connection.new(NexposeIP, NexposeUN, NexposePW)

nsc.login

## Get complete list of Nexpose Vulns -- We will use this later
vuln_list = nsc.list_vulns(full = false)

## Get list of ALL Vuln Exceptions currently in Nexpose
vuln_except_list = nsc.list_vuln_exceptions(status = 'Approved')

## Parse through CSV to populate the hash that was created in the previous step
CSV.foreach('VulnExceptions.csv', {:headers => true}) do |row|

  ## Check what the Action Flag --- 'C' -> Create Vuln Exception
  if row['Action Flag'] == 'C'
    puts "Creating Vuln Exception..."

    ## Find the appropriate Asset Group to Create Vuln Exceptions
    groups = nsc.list_asset_groups
    ag = groups.select{|group_summary| group_summary.name == row['Asset Group Name']}
    ag = AssetGroup.load(nsc, (ag[0].id))

    ## Get the list of Device IDs that are part of the Asset Group
    devices = ag.devices

    ## Get the Vuln Exception Tags
    tags = row['Vuln Exception Tags'].split(',')
		puts "Adding Vuln Exception Tags"
		
    ## Get list of Vulns associated with Each Device/Asset
    devices.each do |asset|
      vulns = nsc.list_device_vulns(asset.id)
     vuln_title = []
      
      vulns.each do |one|
        vuln_title << one.title
      end
        vuln_title = vuln_title.uniq
 
	puts vulns.length
        puts vuln_title.length
      ##Look through Vulns and Exclude ones that meet the Vuln Tags criteria
      vuln_title.each do |vuln|
        tags.each do |vtag|

          ## Check if the Vuln Tag is part of the Vuln Title &  get Vuln ID String
          if vuln.include?(vtag)

            vuln_ids = []
            vuln_list.each do |find|
               if find.title == vuln
                vuln_ids << find.id
                 end
            end
            vuln_ids = vuln_ids.uniq
		puts vuln_ids.length
            vuln_ids.each do |vuln_id|
            ## Setup the initial Vuln Exception
            vexcept = Nexpose::VulnException.new(vuln_id, 'All Instances on a Specific Asset', row['Reason'])

            ## Add the Device scope to the Vuln Exception
            vexcept.device_id = asset.id

            ## Submit Vuln Exception with Submitters Comments
            vexcept.save(nsc, row['Submitter Comments'])

            ## Approve Vuln Exception with Reviewer Comments
            vexcept.approve(nsc, row['Reviewer Comments'])

            ## Add Expiration date to Vuln Exception
            if row['Expiration Date'].nil?
else
vexcept.update_expiration_date(nsc, row['Expiration Date'])
end  
           end
          end
        end
      end
    end

    ## Check what the Action Flag --- 'U' -> Update Vuln Exception
  elsif row['Action Flag'] == 'U'
    puts "Updating Vuln Exception..."

    ## Get list of ALL Vuln Exceptions currently in Nexpose
      ## vuln_except_list = nsc.list_vuln_exceptions(status = 'Approved')

    ## Match Vuln exception based on Reviewer Comments
    vuln_except_list.each do |vexcept|
      if vexcept.reviewer_comment.include?(row['Reviewer Comments'])
			puts "Adding Reviewer Comments"

        ## Update Expiration date on matched Vuln Exception
        vexcept.update_expiration_date(nsc, row['Expiration Date'])
			puts "Setting Expiration Date"
      end

    end

    ## Check what the Action Flag --- 'D' -> Delete Vuln Exception
  elsif row['Action Flag'] == 'D'
    puts "Deleting Vuln Exception..."

    ## Get list of ALL Vuln Exceptions currently in Nexpose
      ##vuln_except_list = nsc.list_vuln_exceptions(status = 'Approved')

    vuln_except_list.each do |vexcept|
      if vexcept.reviewer_comment.include?(row['Reviewer Comments'])

        ## Delete Vuln Exception
        vexcept.delete(nsc)

      end
    end

    ## Check what the Action Flag --- 'A' -> All Vuln Exceptions for Asset Groups
  elsif row['Action Flag'] == 'A' && row['Submitter Comments'] == 'ALL_VULNS'
    puts "Creating Exceptions for ALL vulnerabilities in Asset Group..."

    ## Find the appropriate Asset Group to Create Vuln Exceptions
    groups = nsc.list_asset_groups
    ag = groups.select{|group_summary| group_summary.name == row['Asset Group Name']}
    ag = AssetGroup.load(nsc, (ag[0].id))

    ## Get the list of Device IDs that are part of the Asset Group
    devices = ag.devices

    ## Get list of Vulns associated with Each Device/Asset
    devices.each do |asset|
      vulns = nsc.list_device_vulns(asset.id)

      vuln_title = []
      vulns.each do |one|
        vuln_title << one.title
      end
      vuln_title = vuln_title.uniq
      ##Look through Vulns and Exclude ones that meet the Vuln Tags criteria
      vuln_title.each do |vuln|

        ## Get Vuln ID String
        vuln_ids = []
        vuln_list.each do |find|
          if find.title == vuln
            vuln_ids << find.id
          end
        end
        vuln_ids = vuln_ids.uniq

         vuln_ids.each do |vuln_id|

        ## Setup the initial Vuln Exception
        vexcept = Nexpose::VulnException.new(vuln_id, 'All Instances on a Specific Asset', row['Reason'])

        ## Add the Device scope to the Vuln Exception
        vexcept.device_id = asset.id

        ## Submit Vuln Exception with Submitters Comments
        vexcept.save(nsc, row['Submitter Comments'])

        ## Approve Vuln Exception with Reviewer Comments
        vexcept.approve(nsc, row['Reviewer Comments'])

        ## Add Expiration date to Vuln Exception
        vexcept.update_expiration_date(nsc, row['Expiration Date'])
        end
      end
    end

  end
end

nsc.logout