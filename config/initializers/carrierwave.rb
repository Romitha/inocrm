stfp_server = "192.168.1.146"
CarrierWave.configure do |config|
  config.sftp_host = stfp_server
  config.sftp_user = "dev"
  config.sftp_folder = "/home/dev/inovacrm/#{Rails.env}"
  config.sftp_url = "http://#{stfp_server}/assets/inovacrm/#{Rails.env}"
  config.sftp_options = {
    :password => "dev123",
    :port     => 22
  }
end