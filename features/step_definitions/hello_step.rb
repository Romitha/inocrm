# profile = Selenium::WebDriver::Firefox::Profile.new
# profile.assume_untrusted_certificate_issuer = false
browser = Watir::Browser.new :remote#, url: "http://127.0.0.1:4444/wd/hub"# :chrome#, :profile => 'default'

Given (/^I am on the Guru99 homepage$/)do
  browser.goto "http://demo.guru99.com"
end

When (/^enter blank details for register$/)do
  browser.text_field(:name,"emailid").set(" ")
  browser.button(:name,"btnLogin").click
end

Then (/^error email shown$/)do
  puts "Email is Required!".red
  browser.close
end