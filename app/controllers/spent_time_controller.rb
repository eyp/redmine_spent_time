class SpentTimeController < ApplicationController

  helper :timelog
  include TimelogHelper
  helper :spent_time
  include SpentTimeHelper

  # Show the initial form.
  # * If user has permissions to see spent time for every project
  # the users combobox is filled with all the users.
  # * If user has permissions to see other members' spent times of the projects he works in,
  # the users combobox is filled with their co-workers
  # * If the user only has permissions to see his own report, the users' combobox is filled with the user himself.
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
    @assigned_issues = []
    @same_user = true
  end

  # Show the report of spent time between to dates for an user
  def report
    @user = User.current
    make_time_entry_report(params[:from], params[:to], params[:user])
    another_user = User.find(params[:user])
    @same_user = (@user.id == another_user.id)
    respond_to do |format|
      format.js
    end
  end

  # Delete a time entry
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

  # Create a new time entry
  def create_entry
    @user = User.current

    @time_entry_date = params[:time_entry_spent_on].to_s.to_date
    params[:time_entry][:spent_on] = @time_entry_date
    @from = params[:from].to_s.to_date
    @to = params[:to].to_s.to_date

    # Save the new record
    begin
      @issue = Issue.find(params[:issue_id])
      @project = @issue.project
      @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => @user)
    rescue
      @project = Project.find(params[:project_id]);
      @time_entry ||= TimeEntry.new(:project => @project, :user => @user)
    end

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

  # Update the project's issues when another project is selected
  def update_project_issues
    @to = params[:to].to_date
    @from = params[:from].to_date
    find_assigned_issues_by_project(params[:project_id])
    respond_to do |format|
      format.js
    end
  end
end
