module TwoFactorAuthentication
  class SetupErrorPresenter < TwoFactorAuthentication::SetupPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TranslationHelper

    attr_reader :form

    def initialize(configuration_manager, view, form)
      super(configuration_manager, view)
      @form = form
    end

    def method
      @method ||= begin
        self.class.name.demodulize.sub(/SetupErrorPresenter$/, '').snakecase.to_sym
      end
    end
  end
end
