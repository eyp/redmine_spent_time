# -*- encoding : utf-8 -*-
require 'redmine'

Redmine::Plugin.register :redmine_spent_time do
  name 'Redmine Spent Time plugin'
  author 'Eduardo Yáñez Parareda'
  description 'Redmine\'s plugin to show and load projects\' spent time'
  version '4.1.0'
  requires_redmine '4.0'
  url 'https://github.com/eyp/redmine_spent_time'
  author_url 'https://www.linkedin.com/in/eduardoyanez'

  permission :view_spent_time, {:spent_time => [:index]}
  permission :view_others_spent_time, {:spent_time => [:index]}
  permission :view_every_project_spent_time, {:spent_time => [:index]}
  settings :default => {
      'spent_time_day_length' => 8
  }, :partial => 'spent_time_settings'

  menu(:top_menu,
       :spent_time,
       {:controller => 'spent_time', :action => 'index'},
       :caption => :spent_time_title,
       :if => Proc.new{ User.current.allowed_to?(:view_spent_time, nil, :global => true)})
end

