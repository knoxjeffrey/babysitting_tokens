class MyMailer < MandrillMailer::TemplateMailer
  default from: 'knoxjeffrey@outlook.com'

  def notify_on_user_signup(user)
    
    mandrill_mail(
      template: 'babysitting-tokens-new-user',
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
        'PASSWORD_RESET_URL' => password_reset_url(user.password_token)
      },
      important: true,
      inline_css: true,
     )
  end
  
  def send_invite(group_invitation)
    
    mandrill_mail(
      template: 'babysitting-tokens-friend-invite',
      subject: "Invitation from #{group_invitation.inviter.full_name} to join a Babysitting Tokens group",
      
      from: group_invitation.inviter.email,
      to: group_invitation.friend_email,
      vars: {
        'INVITER_NAME' => group_invitation.inviter.full_name,
        'MESSAGE' => group_invitation.message,
        'INVITATION_URL' => register_with_identifier_url(group_invitation.identifier)
      },
      important: true,
      inline_css: true,
     )
  end
end