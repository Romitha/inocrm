# stfp_server = "192.168.1.146"
# stfp_server = case Rails.env
# when "production" then "192.168.1.146"
# when "staging" then "192.168.100.212"
# else "127.0.0.1"
# end
user = 'dev'
password = 'dev123'
stfp_server = "192.168.1.146"

case Rails.env
when "production"
  stfp_server = "192.168.1.146"

when "staging"
  stfp_server = "192.168.100.212"
  user = 'root'
  password = 'password'
end

CarrierWave.configure do |config|
  config.sftp_host = stfp_server
  config.sftp_user = user
  config.sftp_folder = "/home/dev/inovacrm/#{Rails.env}"
  config.sftp_url = "http://#{stfp_server}/assets/inovacrm/#{Rails.env}"
  config.sftp_options = {
    :password => password,
    :port     => 22
  }
end