module SpentTimeHelper
  def authorized_for?(action)
    User.current.allowed_to?(action, nil, { :global => :true })
  end

  # Devuelve las tareas asignadas al usuario conectado
  def find_assigned_issues
    @user = User.current
    @assigned_issues = []
#    @assigned_issues = [ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ]
    #issues = Issue.find(:all,
                        #:conditions => ["assigned_to_id=? AND #{IssueStatus.table_name}.is_closed=? AND #{Project.table_name}.status=#{Project::STATUS_ACTIVE}", @user.id, false],
                        #:include => [ :status, :project, :tracker, :priority ],
                        #:order => "#{Enumeration.table_name}.position DESC, #{Issue.table_name}.updated_on DESC")
    #issues.each { |issue| @assigned_issues << ["##{issue.id} - #{issue.subject}", issue.id]}
    # De momento no hacemos lo anterior porque aparece una opción en blanco y no sé por qué
    #@assigned_issues = issues
  end

  def find_assigned_issues_by_project(project)
    @user = User.current
    begin
      @project = Project.find(project)
    rescue
      @assigned_issues = []
    else
      # En la consulta se añaden las tareas que aunque no estén asignadas al usuario, éste haya
      # cargado horas
      @assigned_issues = Issue.find(:all,
                          :conditions => ["(assigned_to_id=? or time_entries.user_id=?) AND #{IssueStatus.table_name}.is_closed=? AND #{Project.table_name}.status=#{Project::STATUS_ACTIVE} AND #{Project.table_name}.id=?", @user.id, @user.id, false, @project.id],
                          :include => [ :status, :project, :tracker, :priority, :time_entries ],
                          :order => "#{Enumeration.table_name}.position DESC, #{Issue.table_name}.updated_on DESC",
                          :group => "issues.id")
    end
    @assigned_issues
  end

  # Construye el informe de entradas de tiempos
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
    @assigned_issues = find_assigned_issues
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
    #@to   ||= (TimeEntry.maximum(:spent_on, :include => :project, :conditions => Project.allowed_to_condition(User.current, :view_time_entries)) || Date.today)
    @to   ||= Date.today
  end
end