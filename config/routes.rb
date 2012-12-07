TravelAdvicePublisher::Application.routes.draw do

  namespace :admin do
    root :to => "default#index"
  end

  root :to => redirect('/admin')

end
