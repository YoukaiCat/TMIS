# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'mail'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'contracts'
include Contracts
#~~~~~~~~~~~~~~~~~~~~~~~~~~
class Regexp
  def bmatch(str)
    str =~ self ? true : false
  end
end

class Mailer
  Contract String, String, Proc => Any
  def initialize(email, password, &block)
    @email = Mailer.email_valid?(email) ? email : (raise ArgumentError, "Incorrect email: #{email}")
    @password = password
    set_defaults
    @mail = Mail.new(&block)
    @mail.charset = 'UTF-8'
  end

  Contract String => Bool
  def self.email_valid?(email)
    /[\w\d\._\-]+@[\w\d\.\-]+[\.][\w\d\.\-]+/i.bmatch email
  end

  Contract None => Any
  def send!
    @mail.deliver!
  end

private
  Contract None => ({ local: String, domain: String })
  def email_parts
    @email[/([\w\d._-]+)@([\w\d.-]+)/i]
    { local: $1, domain: $2 }
  end

  Contract None => Any
  def set_defaults
    parts = email_parts
    p email_parts
    pass = @password
    Mail.defaults do
      delivery_method :smtp, {
        address: "smtp.#{parts[:domain]}",
        port: '587',
        user_name: parts[:local],
        password: pass,
        authentication: :plain,
        enable_starttls_auto: true
      }
    end
  end
end
