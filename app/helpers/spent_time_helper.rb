module SpentTimeHelper
  def authorized_for?(action)
    User.current.allowed_to?(action, nil, { :global => :true })
  end

  # Find issues assigned to the user and issues not assigned to him which the user has spent time
  def find_assigned_issues_by_project(project)
    @user = User.current
    begin
      @project = Project.find(project)
    rescue
      @assigned_issues = []
    else
      @assigned_issues = Issue.find(:all,
                          :conditions => ["(#{Issue.table_name}.assigned_to_id=? or #{TimeEntry.table_name}.user_id=?) AND #{IssueStatus.table_name}.is_closed=? AND #{Project.table_name}.status=#{Project::STATUS_ACTIVE} AND #{Project.table_name}.id=?", @user.id, @user.id, false, @project.id],
                          :include => [ :status, :project, :tracker, :priority, :time_entries ],
                          :order => "#{Issue.table_name}.id DESC, #{Issue.table_name}.updated_on DESC")
    end
    @assigned_issues
  end

  # Returns the list of type of activities ordered by name
  def activities_for_select
      collection = activity_collection_for_select_options
      # Gets & removes the first element (--Please select)
      first = collection.shift
      ordered_collection = []
      # Add 'select' label
      ordered_collection << first
      # Order the rest of elements & add them to the collection
      ordered_collection.concat(collection.sort { |a, b| a <=> b })
      ordered_collection
  end
  
  # Render select project as tree
  def render_project_tree    
      select_tag('project_id', "<option value='-1'>-#{l(:select_project_option)}</option>".html_safe +
                           project_tree_options_for_select(user_projects_ordered),
                           {:onchange => "$.post('#{update_project_issues_spent_time_path(:from => @from, :to => @to)}', {'_method':'post', 'project_id':this.value});".html_safe})    
  end

  # Returns the users' projects ordered by name
  def user_projects_ordered
      projects = @user.projects.sort {|a,b| a.name <=> b.name}
      find_assigned_issues_by_project(projects.first) if (projects.length == 1)
      projects
  end

  # Make the spent time report between two dates for a given user
  def make_time_entry_report(from, to, user)
    retrieve_date_range(from, to)
    conditions = "#{TimeEntry.table_name}.user_id = ? AND #{TimeEntry.table_name}.spent_on BETWEEN ? AND ?"

    if (User.exists?(user))
      query_user = User.find(user)
      conditions += " and #{TimeEntry.table_name}.user_id = #{query_user.id}"
    end

    @entries = TimeEntry.find(:all,
            :conditions => [conditions, user, @from, @to],
            :include => [:activity, :project, {:issue => [:tracker, :status]}],
            :order => "#{TimeEntry.table_name}.spent_on DESC, #{Project.table_name}.name ASC, #{Tracker.table_name}.position ASC, #{Issue.table_name}.id ASC")
    @entries_by_date = @entries.group_by(&:spent_on)
    @assigned_issues = []
    @activities = TimeEntryActivity.all
  end

  # Retrieves the date range based on predefined ranges or specific from/to param dates
  def retrieve_date_range(from, to)
    @free_period = false
    @from, @to = nil, nil

    if params[:period_type] == '1' || (params[:period_type].nil? && !params[:period].nil?)
      case params[:period].to_s
      when 'today'
        @from = @to = Date.today
      when 'yesterday'
        @from = @to = Date.today - 1
      when 'current_week'
        @from = Date.today - (Date.today.cwday - 1)%7
        @to = @from + 6
      when 'last_week'
        @from = Date.today - 7 - (Date.today.cwday - 1)%7
        @to = @from + 6
      when 'last_2_weeks'
        @from = Date.today - 14 - (Date.today.cwday - 1)%7
        @to = @from + 13      
      when '7_days'
        @from = Date.today - 7
        @to = Date.today
      when 'current_month'
        @from = Date.civil(Date.today.year, Date.today.month, 1)
        @to = (@from >> 1) - 1
      when 'last_month'
        @from = Date.civil(Date.today.year, Date.today.month, 1) << 1
        @to = (@from >> 1) - 1
      when '30_days'
        @from = Date.today - 30
        @to = Date.today
      when 'current_year'
        @from = Date.civil(Date.today.year, 1, 1)
        @to = Date.civil(Date.today.year, 12, 31)
      end
    elsif params[:period_type] == '2' || (params[:period_type].nil? && (!from.nil? || !to.nil?))
      begin; @from = from.to_s.to_date unless from.blank?; rescue; end
      begin; @to = to.to_s.to_date unless to.blank?; rescue; end
      @free_period = true
    else
      # default
    end

    @from, @to = @to, @from if @from && @to && @from > @to
    @from ||= (TimeEntry.minimum(:spent_on, :include => :project, :conditions => Project.allowed_to_condition(User.current, :view_time_entries)) || Date.today) - 1
    @to   ||= Date.today
  end

  def get_activities(entry)
    activities = []
    entry.project.activities().each {|a| activities << [a.id, a.name]}
    activities
  end
end
