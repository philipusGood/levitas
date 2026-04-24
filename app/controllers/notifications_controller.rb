  class NotificationsController < ApplicationController
    before_action :find_notification, except: [:sidebar, :delete_all]
    before_action :authenticate_user!, except: [:router]

    def router
      @notification.update(read: true)

      path = case @notification.notificable_type
      when "Deal"
        deal_path(@notification.notificable)
      else
        root_path
      end

      redirect_to path
    end

    def sidebar
      @notifications = {
        last_24_hours: current_user.notifications.last_24_hours,
        last_7_days: current_user.notifications.last_7_days,
        older: current_user.notifications.older
      }

      @notifications_empty = @notifications.present? && (!@notifications[:last_24_hours].present? && !@notifications[:last_7_days].present? && !@notifications[:older].present?) 
      render turbo_stream: turbo_stream.update('sidebar_content', partial: '/notifications/sidebar')
    end

    def destroy
      @notification.destroy
      PosthogEventJob.perform_async('Delete Notification', current_user.email, {})

      render turbo_stream: turbo_stream.remove(@notification)
    end

    def delete_all
      current_user.notifications.destroy_all
      PosthogEventJob.perform_async('Delete All Notifications', current_user.email, {})


      render turbo_stream: turbo_stream.remove(current_user.notifications)
    end

    private
    def find_notification
      @notification = current_user.notifications.find(params[:id])
    end
  end
