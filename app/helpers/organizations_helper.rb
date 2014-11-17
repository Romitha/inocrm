module OrganizationsHelper
  def encrypt_org(org)
    crypt.encrypt_and_sign org
  end

  def decrypt_org(org)
    # encrypted_data = encrypt_org(org)
    crypt.decrypt_and_verify(org)
  end

  private
    def crypt
      # salt = SecureRandom.random_bytes(64)
      # key = ActiveSupport::KeyGenerator.new("organization").generate_key(salt)
      ActiveSupport::MessageEncryptor.new("organization12345678123456781234")
    end
end