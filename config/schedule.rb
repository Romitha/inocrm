# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "#{path}/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 1.hour do
	command "mysqldump -uroot -pmysql --skip-triggers --compact --no-create-info inocrm_dev > #{path}/timestamp_$(date +\%Y\%m\%d\%H\%M\%S).sql"
	# command "mysqldump -uroot -h192.168.100.156 -pVsisInoCrm_app_123 inova_crm_pro > /root/Dropbox-Uploader/timestamp_$(date +\%Y\%m\%d\%H\%M\%S).sql"
	# Visit http://dev.mysql.com/doc/refman/5.7/en/mysqldump.html for more argument info
	# command "/Users/umeshblader/Projects/git/Dropbox-Uploader/dropbox_uploader.sh upload "

end

# every 6.hours do
#   rake "flush_logfile -- -p='#{shared_path}' -s='production' "

# end