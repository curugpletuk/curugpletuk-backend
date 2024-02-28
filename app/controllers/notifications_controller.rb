class NotificationsController < ApplicationController
  before_action :authenticate_request!
  
  def index
    notifications = Notification.order("created_at DESC").where("user_id = ?", @user.id)
    return render json: { code: 200, status: "OK", data: { notifications: notifications }}
    # get_data_success_response({ code: 200, status: "OK", data: { notifications: notifications }})
  end
end
