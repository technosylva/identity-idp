module TwoFactorAuthentication
  class VerifyForm
    include ActiveModel::Model

    attr_accessor :user, :configuration_manager

    validates :user, presence: true
    validates :configuration_manager, presence: true

    def method
      @method ||= self.class.name.demodulize.sub(/VerifyForm$/, '').snakecase.to_sym
    end

    def extra_analytics_attributes
      {
        multi_factor_auth_method: method,
      }
    end
  end
end
