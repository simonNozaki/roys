class ApplicationController < ActionController::Base
  def hello
    render html: "Hello, Rails!"
  end

  def goodbye
    render html: "Goodbye, Rails!"
  end
end
