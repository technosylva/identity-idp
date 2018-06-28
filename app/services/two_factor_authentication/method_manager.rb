module TwoFactorAuthentication
  class MethodManager
    attr_reader :user

    NON_PHONE_METHODS = %i[totp piv_cac]

    def initialize(user)
      @user = user
    end

    def configuration_managers
      methods.map(&method(:configuration_manager))
    end

    # TODO: allow multiple selection presenters for a single method if that method
    # supports multiple configurations. We really want one presenter per
    # configuration for configured/enabled setups and one presenter per method for
    # configurable methods.

    # Used when presenting the user with a list of options during login
    def enabled_selection_presenters(view)
      configuration_managers.select(&:enabled?).map do |manager|
        manager.selection_presenter(view)
      end
    end

    # Used when presenting the user with a list of options during setup
    def configurable_selection_presenters(view)
      configuration_managers.select(&:configurable?).map do |manager|
        manager.selection_presenter(view)
      end
    end

    def configuration_manager(method)
      class_constant(method, 'ConfigurationManager')&.new(user)
    end

    private

    def class_constant(method, suffix)
      ('TwoFactorAuthentication::' + method.to_s.camelcase + suffix).safe_constantize
    end

    # TODO: filter based on configuration - allow some methods in some environments, etc.
    def methods
      phone_methods = if user.otp_delivery_preference == :sms
        %i[sms voice]
      else
        %i[voice sms]
      end

      phone_methods + NON_PHONE_METHODS
    end
  end
end
