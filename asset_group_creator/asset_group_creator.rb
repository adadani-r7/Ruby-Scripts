############################################################################
# Copyright (c) Rapid7, LLC 2016 All Right Reserved, http://www.rapid7.com/
# All rights reserved. This material contains unpublished, copyrighted
# work including confidential and proprietary information of Rapid7.
############################################################################
#
# asset_group_creator.rb
#
# Script version: 0.02
# Nexpose Version:
# Ruby Version:
# Gem Version:
#
# Author: Aniket Menon
# Email:  Aniket_Menon@rapid7.com
# Date:   12/09/2015
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
# KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
# PARTICULAR PURPOSE.
#
# Tags: dynamic asset group, assets
# 
# Description:
# The script reads in a list of IPs and adds them to an asset group
#
require 'set'
require 'nexpose'

include Nexpose



nsc = Nexpose::Connection.new('IP', 'UN', 'PW')
nsc.login

Dir.glob("/<DIR PATH>/") do |my_text_file|

  file_name = my_text_file
  file = file_name.sub(".txt",'')

  begin

## Checking for Asset Group
    asset_groups = nsc.list_asset_groups

    asset_group = asset_groups.select{|site_summary| site_summary.name == file}

    asset_group = Nexpose::AssetGroup.load(nsc, (asset_group[0].id))
  rescue

## Creating Asset Group
    asset_group = AssetGroup.new(file,file,id= -1,risk = 0.0)

  end

  File.open(my_text_file).each_line do |x|
    dev_in = []
  nsc.list_site_devices.each do |device|

    if device.address.include? x
     dev_in << device
      puts x

    end
  end
      dev_in.each do |dev|
        puts dev
       next if asset_group.devices.include?(dev)
        asset_group.devices << dev
      end

    asset_group.save(nsc)
  end

end
## Logging out of Nexpose
nsc.logout