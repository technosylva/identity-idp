module TwoFactorAuthentication
  class SetupForm
    include ActiveModel::Model

    attr_accessor :user, :configuration_manager

    validates :user, presence: true
    validates :configuration_manager, presence: true

    def method
      @method ||= self.class.name.demodulize.sub(/SubmitForm$/, '').snakecase.to_sym
    end
  end
end
