require "json"

module Gatleon
  module Authform
    module Rails
      class User
        PERMITTED_CHARS = /\A[a-zA-Z0-9_)]*\z/

        def initialize(_cookies:,
                       _form_public_key:,
                       _form_secret_key:,
                       _domain:,
                       _authform_base_url:)
          @_cookies = _cookies
          @_form_public_key = _form_public_key
          @_form_secret_key = _form_secret_key
          @_domain = _domain
          @_authform_base_url = _authform_base_url

          parse!
        end

        def parse!
          !!_id
        rescue
          raise Gatleon::Authform::Rails::Error
        end

        # Getters
        #
        def _id
          data["_id"]
        end

        def _email
          data["_email"]
        end

        # Getters
        #
        def [](key)
          data[key.to_s]
        end

        # Setters
        #
        def []=(key, value)
          key = _clean_key(key)

          raise Gatleon::Authform::Rails::Error, "can't set reserved field name #{key}" if key[0] == "_" # anything starting with _

          raise Gatleon::Authform::Rails::Error, "can't set empty field name" if key == ""

          raise Gatleon::Authform::Rails::Error, "only characters a-z, A-Z, 0-9, and _ permitted in field name" unless key.match?(PERMITTED_CHARS)

          data[key] = value.to_s
        end

        def data
          _json["data"]
        end

        def _json
          @_json ||= JSON.parse(@_cookies[@_form_public_key])
        end

        def signoff!
          if @_domain
            @_cookies.delete(@_form_public_key, domain: @_domain)
          else
            @_cookies.delete(@_form_public_key)
          end
        end
        alias_method :sign_off!, :signoff!
        alias_method :signout!, :signoff!
        alias_method :sign_out!, :signoff!
        alias_method :logout!, :signoff!
        alias_method :log_out!, :signoff!
        alias_method :logoff!, :signoff!
        alias_method :log_off!, :signoff!

        private

        def _persist(key, value)
          uri = _persist_url(key, vlue)
          
          Net::HTTP.get_response(uri) # TODO: move to post request
        end

        def _persist_url(key, value)
          URI("#{@_authform_base_url}/v1/setUser?_id=#{_id}&_secretKey=#{@_form_secret_key}&#{key}=#{value}")
        end

        def _clean_key(k_or_v)
          k_or_v.to_s.strip
        end
      end
    end
  end
end

