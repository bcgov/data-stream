class ApplicationMailer < ActionMailer::Base
  default from: "hello@myapp.com"
  default :from_name => ENV['EMAIL_FROM_NAME'] || 'The team of Myapp'
  default :from_address => ENV['EMAIL_FROM'] || 'hello@myapp.com'
  default :reply_to => ENV['EMAIL_FROM'] || 'hello@myapp.com'

end
