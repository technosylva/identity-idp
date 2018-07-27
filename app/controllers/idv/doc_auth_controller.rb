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
        user_session[:id_profile] = map_id_data_to_profile(user_session_doc_auth[:id_data][:Fields])
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
      redirect_to idv_session_url
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

    def map_id_data_to_profile(id_data_fields)
      field_map = {
        state_id_number: 'Document Number',
        state_id_jurisdiction: 'Issuing State Code',
        first_name: 'First Name',
        middle_name: 'Middle Name',
        last_name: 'Surname',
        address1: 'Address Line 1',
        address2: 'Address Line 2',
        city: 'Address City',
        state: 'Address State',
        zipcode: 'Address Postal Code',
        dob: 'Birth Date',
      }

      result = field_map.transform_values do |id_data_field_name|
        id_data_field = id_data_fields.detect { |id_data_field| id_data_field.fetch(:Name) == id_data_field_name }
        id_data_field&.fetch(:Value)
      end
      result[:state_id_type] = 'drivers_license'
      result[:dob] = convert_date(result[:dob])
      result
    end

    def convert_date(date)
      Date.strptime((date[6..-3].to_f / 1000).to_s, '%s').strftime('%m/%d/%Y')
    end
  end
end
