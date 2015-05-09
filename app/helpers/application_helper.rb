module ApplicationHelper
  #modify date presentation.
  #
  #example Jan 4th, 2015
  def display_friendly_date(date)
    date.strftime("%b #{date.day.ordinalize}, %Y")
  end
  
  def display_time(datetime)
    datetime.strftime("%H:%M")
  end
  
  def display_friendly_date_and_time(date)
    date.strftime("%b #{date.day.ordinalize}, %Y at %H:%M")
  end
  
  def row_color(status)
    status == 'waiting' ? 'warning' : 'success'
  end
  
  def display_next_baby_sitting_date_info(request)
    " #{display_friendly_date_and_time(request.start)} for #{request.user.full_name}"
  end
  
  def avatar_url(email, size)
    user = User.find_by(email: email)
    
    if user.avatar.present?
      "http://res.cloudinary.com/da6v0vrqx/image/upload/w_#{size},h_#{size},c_fill,g_face,r_max/#{user.avatar.filename}"
    elsif user.authentications.present?
      "http://graph.facebook.com/#{user.authentications.last.uid}/picture?width=#{size}&height=#{size}"
    else
      "http://res.cloudinary.com/da6v0vrqx/image/upload/w_#{size},h_#{size},c_fill,g_face,r_max/v1431133723/default_avatar_zdyioa.png"
    end
  end
  
  def request_to_join_group_button(user, group)
    if current_user.groups.include? group
      content_tag :div, "Already A Member",  class: "btn bg-red btn-flat btn-xs"
    else
      link_to "Request To Join Group", "/join_group_requests?user_id=#{user.id}&group_id=#{group.id}", method: :post , class: "btn bg-olive btn-flat btn-xs"
    end
  end
  
  # Used to inject styles into application.html.haml so I can add a class to body
  def body_class(class_name="")
    content_for :body_class, class_name
  end
  
  # Used to inject styles into application.html.haml so I can add a class to content_wrapper
  def content_wrapper_class(class_name="")
    content_for :content_wrapper_class, class_name
  end
  
end