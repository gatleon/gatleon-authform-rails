![authform-rails](https://raw.githubusercontent.com/gatleon/gatleon-authform-rails/master/gatleon-authform-rails.png)

# authform-rails by gatleon

add authentication to your application - in 1 minute or less.

## installation

add this line to your application's Gemfile:

```ruby
gem "gatleon-authform-rails"
```

and then execute:

```
$ bundle install
```

add a profile controller

```ruby
class ProfileController < ActionController::Base
  AUTHFORM_FORM_SECRET_KEY = "" # Available at https://authform.gatleon.com. coming soon!
  AUTHFORM_FORM_PUBLIC_KEY = "" # Available at https://authform.gatleon.com. coming soon!

  include Gatleon::Authform::Rails::Concern.new(public_key: AUTHFORM_FORM_PUBLIC_KEY, secret_key: AUTHFORM_FORM_SECRET_KEY)

  before_action :require_login, only: [:index]

  def index
    erb = <<~ERB
      <h1>Profile</h1>
      <p style="color: green;">You are signed in.</p>
      <p><%= current_user %></p>
    ERB

    render inline: erb
  end

  def signin
    erb = <<~ERB
      <p style="color: red;"><%= flash[:error] %></p>
      <h1>Sign In</h1>
      <form action="https://authform.gatleon.com/v1/form/<%= ProfileController::AUTHFORM_FORM_PUBLIC_KEY %>" method="POST">
        <input type="email" name="email">
        <button type="submit">Sign In</button>
      </form>
    ERB

    render inline: erb
  end

  private

  def require_login
    unless current_user
      flash[:error] = "Sign in, please."

      redirect_to(profile_signin_path) and return
    end
  end
end
```

add profile routes to routes.rb

```ruby
Rails.application.routes.draw do
  get '/profile', to: 'profile#index', as: 'profile'
  get '/profile/signin', to: 'profile#signin', as: 'profile_signin'
end
```

that's it!

## license

the gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

