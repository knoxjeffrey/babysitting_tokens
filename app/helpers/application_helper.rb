module ApplicationHelper
  #modify date presentation.
  #
  #example Jan 4th, 2015 20:52 UTC
  def display_friendly_date(date)
    date.strftime("%b #{date.day.ordinalize}, %Y")
  end
  
  def row_color(status)
    status == 'waiting' ? 'warning' : 'success'
  end
end
