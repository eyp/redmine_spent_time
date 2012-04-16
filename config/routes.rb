ActionController::Routing::Routes.draw do |map|
  map.connect '/spent_time/update_users_select', :controller => 'spent_time', :action => 'update_users_select'
  map.connect '/spent_time/update_project_issues', :controller => 'spent_time', :action => 'update_project_issues'
  map.connect '/spent_time/create_entry', :controller => 'spent_time', :action => 'create_entry'
  map.connect '/spent_time/destroy_entry', :controller => 'spent_time', :action => 'destroy_entry'  
  map.connect '/spent_time/report', :controller => 'spent_time', :action => 'report'  
  map.connect '/spent_time', :controller => 'spent_time', :action => 'index'
end