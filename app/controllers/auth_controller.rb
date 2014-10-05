class AuthController < ApplicationController
	before_action :authenticate_user!, only: [:edit]
  def index
  	key = 'key'
		data = 'The quick brown fox jumps over the lazy dog'
		digest = OpenSSL::Digest.new('sha1')

		@hmac = OpenSSL::HMAC.hexdigest(digest, key, data)
		# http://www.ruby-doc.org/stdlib-2.1.2/libdoc/openssl/rdoc/OpenSSL/HMAC.html
    cookies[:loginerr] = { value: "XJ-122", expires: 1.hour.from_now, secure: true, domain: :all } if cookies[:loginerr].blank?
  end

  def edit
  	
  end
end
