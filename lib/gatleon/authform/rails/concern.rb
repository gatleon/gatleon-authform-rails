require "xxhash"

module Gatleon
  module Authform
    module Rails
      class Concern < Module
        def initialize(public_key:,
                       secret_key:,
                       domain: nil,
                       current_user_method_name: "current_user",
                       _authform_base_url: "https://authformapi.gatleon.com")
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
                Gatleon::Authform::Rails::User.new(_cookies: cookies,
                                                   _authform_user_cookie_key: _authform_user_cookie_key,
                                                   _form_secret_key: secret_key,
                                                   _domain: domain,
                                                   _authform_base_url: _authform_base_url)
              rescue
                nil
              end
            end

            define_method :_exchange_user_voucher_for_user do
              if params[:_authformForm] == public_key && params[:_authformUserVoucher]
                # TODO: headers for api verification
                
                uri = URI("#{_authform_base_url}/v1/exchangeUserVoucherForUser/#{params[:_authformUserVoucher]}")
                response = Net::HTTP.get_response(uri)

                cookies[_authform_user_cookie_key] = _cookie_attrs(response.body) if response.code.to_i == 200

                q = Rack::Utils.parse_query(URI.parse(request.url).query)
                q.delete("_authformUserVoucher")
                q.delete("_authformForm")
                url = q.empty? ? request.path : "#{request.path}?#{q.to_query}"

                redirect_to url, status: 302 # redirect to finish removal of query param
              end
            end

            define_method :_authform_user_cookie_key do
             "#{public_key}_#{XXhash.xxh32(domain)}"
            end

            define_method :_cookie_attrs do |value|
              {
                value: value,
                domain: domain
              }.compact
            end
          end
        end
      end
    end
  end
end

