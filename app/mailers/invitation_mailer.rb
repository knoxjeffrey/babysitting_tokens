class InvitationMailer < MandrillMailer::TemplateMailer
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
end