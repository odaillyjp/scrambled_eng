module ApplicationHelper
  def dashboard_class_value(current_item)
    nav_item_class_value(:dashboard, current_item)
  end

  def create_challenge_class_value(current_item)
    nav_item_class_value(:create_challenge, current_item)
  end

  def edit_course_class_value(current_item)
    nav_item_class_value(:edit_course, current_item)
  end

  private

  def nav_item_class_value(nav_item, current_item)
    classes = ['course-management__nav-item']
    classes << 'is-current' if nav_item == current_item
    classes.join(' ')
  end
end
