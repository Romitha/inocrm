CarrierWave.configure do |config|
  config.sftp_host = "192.168.1.193"
  config.sftp_user = "dev"
  config.sftp_folder = "/home/dev/inovacrm"
  config.sftp_url = "http://192.168.1.193/assets/inovacrm"
  config.sftp_options = {
    :password => "dev123",
    :port     => 22
  }
end