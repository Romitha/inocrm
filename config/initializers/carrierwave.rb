# stfp_server = "192.168.1.146"
# stfp_server = case Rails.env
# when "production" then "192.168.1.146"
# when "staging" then "192.168.100.212"
# else "127.0.0.1"
# end
user = 'root'
password = 'centos'
stfp_server = "192.168.1.146"

case Rails.env
when "production"
  stfp_server = "192.168.1.146"
  # sftp_folder = "/home/dev/inovacrm/#{Rails.env}"
  # If alias is set in nginx conf file, inovacrm-assets folder must be parallel to inocrm project folder
  sftp_folder = "/var/www/inovacrm-assets/#{Rails.env}"
when "bobbin"
  stfp_server = "192.168.1.126"
  sftp_folder = "/home/dev/inovacrm/#{Rails.env}"

when "staging"
  stfp_server = "192.168.50.155"
  user = 'root'
  password = 'redhat'
  sftp_folder = "/var/www/inovacrm_assets/#{Rails.env}"
end

CarrierWave.configure do |config|
  config.sftp_host = stfp_server
  config.sftp_user = user
  config.sftp_folder = sftp_folder
  config.sftp_url = "http://#{stfp_server}/assets/inovacrm/#{Rails.env}"
  config.sftp_options = {
    :password => password,
    :port     => 22
  }
end