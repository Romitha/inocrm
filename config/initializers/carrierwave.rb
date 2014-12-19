CarrierWave.configure do |config|
  config.sftp_host = "192.168.1.193"
  config.sftp_user = "dev"
  config.sftp_folder = "/home/dev/inovacrm/#{Rails.env}"
  config.sftp_url = "http://192.168.1.193/assets/inovacrm/#{Rails.env}"
  config.sftp_options = {
    :password => "dev123",
    :port     => 22
  }
end