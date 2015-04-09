# -*- encoding : utf-8 -*-
RedmineApp::Application.routes.draw do
  match '/spent_time/update_project_issues', to: 'spent_time#update_project_issues', as: 'update_project_issues_spent_time', :via => [:post]
  match '/spent_time/create_entry', to: 'spent_time#create_entry', as: 'create_entry_spent_time', :via => [:post]
  #match '/spent_time/update_entry', to: 'spent_time#update_entry', as: 'update_entry_spent_time', :via => [:put]
  get '/spent_time/destroy_entry', to: 'spent_time#destroy_entry', as: 'destroy_entry_spent_time'
  match '/spent_time/report', to: 'spent_time#report', as: 'report_spent_time', :via => [:get, :post]
  match '/spent_time', to: 'spent_time#index', as: 'index_spent_time', :via => [:get, :post]
end
