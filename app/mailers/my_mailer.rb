class MyMailer < MandrillMailer::TemplateMailer
  default from: 'info@timeofftokens.com'

  def notify_on_user_signup(user)
    
    mandrill_mail(
      template: 'babysitting-tokens-new-user',
      subject: 'Welcome from Time Off Tokens',

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
      subject: 'Reset Password For Time Off Tokens',

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
      subject: "Invitation from #{group_invitation.inviter.full_name} to join a Time Off Tokens babysitting circle",
      
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
  
  def send_request_to_join_group(request_to_join_group)
    
    mandrill_mail(
      template: 'babysitting-tokens-request-to-join-group',
      subject: "Request by #{request_to_join_group.requester.full_name} to your group #{request_to_join_group.group.group_name}",
      
      from: request_to_join_group.requester.email,
      to: request_to_join_group.group_member.email,
      vars: {
        'REQUESTER_NAME' => request_to_join_group.requester.full_name,
        'GROUP_NAME' => request_to_join_group.group.group_name,
        'REQUEST_TO_JOIN_GROUP_URL' => join_user_group_with_identifier_url(request_to_join_group.identifier)
      },
      important: true,
      inline_css: true,
     )
  end
  
  def send_confirmation_joined_group(join_group_request)
    
    mandrill_mail(
      template: 'babysitting-tokens-confirmation-joined-group',
      subject: "You have been accepted to #{join_group_request.group.group_name}",

      to: join_group_request.requester.email,
      vars: {
        'REQUESTER_NAME' => join_group_request.requester.full_name,
        'GROUP_NAME' => join_group_request.group.group_name
      },
      important: true,
      inline_css: true,
     )
  end
  
  def notify_user_that_babysitter_canceled(request)
    
    babysitter = User.find(request.babysitter_id)
    mandrill_mail(
      template: 'babysitting-tokens-cancel-babysitting-agreement',
      subject: "#{babysitter.full_name} has had to cancel their date to babysit for you",
      
      from: babysitter.email,
      to: request.user.email,
      vars: {
        'BABYSITTER_NAME' => babysitter.full_name,
        'GROUP_NAME' => request.group.group_name,
        'BABYSITTING_DATE' => request.start.strftime("%b #{request.start.day.ordinalize}, %Y")
      },
      important: true,
      inline_css: true,
     )
  end
  
  def notify_users_of_request(user_group_email_and_name_array_of_hashes, request)

    mandrill_mail(
      template: 'babysitting-tokens-request-a-sitter',
      subject: "#{request.user.full_name} needs a babysitter!",
      
      from: request.user.email,
      to: user_group_email_and_name_array_of_hashes,
      vars: {
        'REQUESTER_NAME' => request.user.full_name,
        'REQUEST_DATE' => request.start.strftime("%b #{request.start.day.ordinalize}, %Y"),
        'HOME_URL' => home_url
      },
      important: true,
      inline_css: true,
     )
  end
  
end