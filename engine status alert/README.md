## Nexpose Engine Status Alert

### About
This script is intended to send an email alert when engines return a status of "Not responding" or "Unknown".  This
will help identify engines that have been paired with the console but are not functioning or available at the time.

This has been tested against the Google SMTP servers and may need slight modifications for internal SMTP endpoints.

### Usage
Configure the nexpose connection details:
```
nx = { :host => '127.0.0.1', :port => '3780', :user => 'nxadmin', :password => 'nxpassword' }
```
Configure the SMTP connection details:
```
mail = { :host => 'smtp.sample.com', :port => 25, :helo => 'sample.com',
         :user => 'user@sample.com', :password => 'password' }
```
Configure the To and From details for the message:
```
delivery = { :from => 'noreply@sample.com', :to => ['recipient1@sample.com','recipient2@sample.com'] }
```

Run script:
```
ruby nx_engine_status_alert.rb
```

