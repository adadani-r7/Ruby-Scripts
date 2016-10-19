#!/usr/bin/env ruby

require 'nexpose'
require 'net/smtp'

def nexpose_connection(host, port, user, password)
  begin
    nsc = Nexpose::Connection.new(host, user, password, port)
    return nsc
  rescue
    abort('Failed to connect to Nexpose Console')
  end
end

def send_alert(engine,mail,delivery)
  subject = "Nexpose Engine (#{engine}) Not Available"
  message = <<MESSAGE_END
From: #{delivery[:from]}
To: #{delivery[:to]}
Subject: #{subject}

Nexpose Engine Unavailable: #{engine}
MESSAGE_END

  begin
    smtp = Net::SMTP.new mail[:host], mail[:port]
    smtp.enable_starttls
    smtp.start mail[:helo], mail[:user], mail[:password], :login do
      smtp.send_message(message, delivery[:from], delivery[:to])
    end

    puts "Alert sent for #{engine}"
  rescue Exception => e
    raise "Something bad happened: #{e}"
    exit -1
  end
end

## Main ##
nx = { :host => '127.0.0.1', :port => '3780', :user => 'nxadmin', :password => 'nxpassword' }
mail = { :host => 'smtp.sample.com', :port => 25, :helo => 'sample.com',
         :user => 'user@sample.com', :password => 'password' }
delivery = { :from => 'noreply@sample.com', :to => ['recipient1@sample.com','recipient2@sample.com'] }

nsc = nexpose_connection(nx[:host],nx[:port],nx[:user],nx[:password])
nsc.login

nsc.list_engines.each do | engine |
  puts "Engine: #{engine.name}; Status #{engine.status}"
  send_alert(engine.name,mail,delivery) if engine.status == 'Not responding' || engine.status == 'Unknown'
end