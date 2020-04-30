module Gatleon
  module Authform
    module Rails
      class Concern < Module
        def initialize(public_key:,
                       secret_key:,
                       current_user_method_name: "current_user",
                       _authform_base_url: "https://authform.gatleon.com")
          super() do
            extend ActiveSupport::Concern

            included do
              helper_method "#{current_user_method_name}".to_sym
              before_action :_exchange_user_voucher_for_user
            end

            private

            # defaults to current_user
            define_method current_user_method_name do
              begin
                json = JSON.parse(cookies[_authform_user_cookie_key])["data"]

                Gatleon::Authform::Rails::User.new(json: json, _form_secret_key: secret_key, _authform_base_url: _authform_base_url)
              rescue
                nil
              end
            end

            define_method :_exchange_user_voucher_for_user do
              if params[:_authformForm] == public_key && params[:_authformUserVoucher]
                # TODO: headers for api verification
                
                uri = URI("#{_authform_base_url}/v1/exchangeUserVoucherForUser/#{params[:_authformUserVoucher]}")
                response = Net::HTTP.get_response(uri)

                if response.code.to_i == 200
                  # First attempt WITHOUT all - for setting on platforms like heroku that deny setting cookies across all subdomains
                  cookies[_authform_user_cookie_key] = {
                    value: response.body
                  }

                  # Then set all - desired behavior for hosting your own domain
                  cookies[_authform_user_cookie_key] = {
                    value: response.body,
                    domain: :all
                  }
                end

                q = Rack::Utils.parse_query(URI.parse(request.url).query)
                q.delete("_authformUserVoucher")
                q.delete("_authformForm")
                url = q.empty? ? request.path : "#{request.path}?#{q.to_query}"

                redirect_to url, status: 302 # redirect to finish removal of query param
              end
            end

            define_method :_authform_user_cookie_key do
              public_key # allows for multiple forms per site
            end
          end
        end
      end
    end
  end
end

