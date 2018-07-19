module Idv
  class DocAuthController < ApplicationController
    before_action :confirm_two_factor_authenticated

    USER_SESSION_DOC_AUTH_KEY = :doc_auth

    before_action :set_doc_auth

    attr_accessor :doc_auth

    def clear
      remove_user_session_doc_auth
      redirect_to idv_doc_auth_url
    end

    def index
      redirect_to_step(doc_auth.next_step)
    end

    def show
      render_step(params[:step], doc_auth.session)
    end

    def update
      current_step = params[:step]
      result = doc_auth.handle(current_step, doc_auth_params)

      if doc_auth.completed?
        remove_user_session_doc_auth
        redirect_to_success and return
      end

      if result.success?
        update_user_session_doc_auth(doc_auth.session)
        redirect_to_step(doc_auth.next_step) and return
      end

      render_step(current_step, doc_auth.session)
    end

    def doc_auth_params
      params.require(:doc_auth).permit(:image)
    end

    private

    def set_doc_auth
      @doc_auth ||= Idv::DocAuth.new(user_session_doc_auth)
    end

    def render_step(step, doc_auth_session)
      render template: "idv/doc_auth/#{step}", locals: { doc_auth_session: doc_auth_session }
    end

    def redirect_to_step(step)
      redirect_to idv_doc_auth_step_url(step: step)
    end

    def redirect_to_success
      redirect_to idv_session_success_url
    end

    def user_session_doc_auth
      user_session[USER_SESSION_DOC_AUTH_KEY]
    end

    def update_user_session_doc_auth(doc_auth_session)
      user_session[USER_SESSION_DOC_AUTH_KEY] = doc_auth_session
    end

    def remove_user_session_doc_auth
      user_session.delete(USER_SESSION_DOC_AUTH_KEY)
    end
  end
end
