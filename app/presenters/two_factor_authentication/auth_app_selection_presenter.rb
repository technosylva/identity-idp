module TwoFactorAuthentication
  class AuthAppSelectionPresenter < SelectionPresenter
    def method
      :auth_app
    end

    def recommended?
      false
    end
  end
end
