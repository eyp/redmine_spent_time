class SpentTimeController < ApplicationController

  helper :timelog
  include TimelogHelper
  helper :spent_time
  include SpentTimeHelper

  def index
    @user = User.current
    if (authorized_for?(:view_every_project_spent_time))
      @users = User.find(:all, :conditions => ["status = 1"])
    elsif (authorized_for?(:view_others_spent_time))
      projects = User.current.projects
      @users = []
      projects.each { |project| @users.concat(project.users) }
      @users.uniq!
    else
      @users = [@user]
    end
    @users.sort! { |a, b| a.name <=> b.name }
    @assigned_issues = find_assigned_issues
    @same_user = true
  end

  def report
    @user = User.current
    make_time_entry_report(params[:from], params[:to], params[:user])
    another_user = User.find(params[:user])
    @same_user = (@user.id == another_user.id)
    respond_to do |format|
      format.html { render :partial => 'report'}
      #format.csv  { send_data(report_to_csv(@criterias, @periods, @hours).read, :type => 'text/csv; header=present', :filename => 'timelog.csv') }
    end
  end

  def destroy_entry
    @time_entry = TimeEntry.find(params[:id])
    render_404 and return unless @time_entry
    render_403 and return unless @time_entry.editable_by?(User.current)
    @time_entry.destroy

    @user = User.current
    @from = params[:from].to_s.to_date
    @to = params[:to].to_s.to_date
    make_time_entry_report(params[:from], params[:to], @user)
    respond_to do |format|
      format.js
    end
  rescue ::ActionController::RedirectBackError
    redirect_to :action => 'index'
  end

  def create_entry
    @user = User.current

    @time_entry_date = params[:time_entry_spent_on].to_s.to_date
    params[:time_entry][:spent_on] = @time_entry_date
    @from = params[:from].to_s.to_date
    @to = params[:to].to_s.to_date

    # Persistimos el nuevo registro
    @issue = Issue.find(params[:time_entry][:issue_id])
    @project = @issue.project
    @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => @user)
    @time_entry.attributes = params[:time_entry]
    render_403 and return if @time_entry && !@time_entry.editable_by?(@user)
    @time_entry.user = @user
    @time_entry.save!

    respond_to do |format|
      if @time_entry_date > @to
        @to = @time_entry_date
      elsif @time_entry_date < @from
        @from = @time_entry_date
      end
      make_time_entry_report(@from, @to, @user)
      format.js
    end
  end

  def update_project_issues
    find_assigned_issues_by_project(params[:select_project])
    render :update do |page|
      page.replace_html "fields_for_new_entry_form", :partial => "fields_for_new_entry_form"
    end
  end

  # Actualiza el select de las personas después de haber elegido un proyecto
  def update_users_select
    if Project.exists?(params[:value])
      project = Project.find(params[:value])
      @users = project.users
    else
      @users = User.find(:all, :conditions => ["status = 1"])
    end

    render :update do |page|
      page.replace_html "people_select", :partial => "people_select"
    end
  end
end
