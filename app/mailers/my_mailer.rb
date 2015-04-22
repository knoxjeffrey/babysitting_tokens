class MyMailer < MandrillMailer::TemplateMailer
  default from: 'knoxjeffrey@outlook.com'

  def notify_on_user_signup(user)
    
    mandrill_mail(
      template: 'freedom-tokens-new-user',
      subject: 'Welcome from Babysitting Tokens',

      to: user.email,
      vars: {
        'USER_NAME' => user.full_name
      },
      important: true,
      inline_css: true,
     )
  end
  
  def send_forgot_password(user)
    
    mandrill_mail(
      template: 'babysitting-tokens-reset-password',
      subject: 'Reset Password For Babysitting Tokens',

      to: user.email,
      vars: {
        'USER_NAME' => user.full_name,
        'PASSWORD_RESET_URL' => password_reset_url(user.password_token),
      },
      important: true,
      inline_css: true,
     )
  end
end