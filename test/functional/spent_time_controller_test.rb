require_relative '../test_helper'

class SpentTimeControllerTest < Redmine::ControllerTest
  include Redmine::I18n

  def setup
    super
    Setting.default_language = 'en'
    @request.session[:user_id] = 1
  end

  def test_index
    get :index
    assert_response :success
  end

  def test_index_with_period
    get :index, params: { period: '30_days' }
    assert_response :success
  end

  def test_index_with_all_period
    get :index, params: { period: 'all', period_type: '1' }
    assert_response :success
  end

  def test_report
    get :index
    post :report, params: { user: 2, from: (Date.today - 7).to_s, to: Date.today.to_s }, xhr: true
    assert_response :success
  end

  def test_index_renders_no_missing_translations
    get :index
    assert_response :success
    missing = response.body.scan(/translation missing:?\s*[\w.]*/i)
    assert_empty missing, "Untranslated keys rendered: #{missing.uniq.join(', ')}"
  end

  # Redmine 7.0 dropped label_date_from/label_date_to from its core locales
  # (redmine.org patch #44065), so the plugin has to ship them itself.
  def test_shipped_locales_define_the_labels_not_provided_by_core
    files = Dir[File.expand_path('../../config/locales/*.yml', __dir__)].sort
    assert_not_empty files
    files.each do |file|
      translations = YAML.safe_load(File.read(file, encoding: 'bom|utf-8'))
      locale = translations.keys.first
      %w(label_date_from label_date_to label_all_time).each do |key|
        assert translations[locale].key?(key), "#{File.basename(file)} is missing #{key}"
      end
    end
  end
end
