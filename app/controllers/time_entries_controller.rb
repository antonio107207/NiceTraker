class TimeEntriesController < ApplicationController
  before_action :set_card,  only: %i[create]
  before_action :set_entry, only: %i[update destroy]

  def create
    authorize TimeEntry.new(card: @card, user: current_user)

    minutes = TimeEntry.parse_duration(params.dig(:time_entry, :duration))
    if minutes
      @entry = @card.time_entries.create!(
        user: current_user,
        minutes: minutes,
        description: params.dig(:time_entry, :description).presence,
        logged_at: Time.current
      )
    end

    if params.dig(:time_entry, :estimate).present?
      estimate = TimeEntry.parse_duration(params.dig(:time_entry, :estimate))
      @card.update!(estimated_minutes: estimate)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  def update
    authorize @entry
    minutes = TimeEntry.parse_duration(params.dig(:time_entry, :duration))
    @entry.update!(
      minutes: minutes || @entry.minutes,
      description: params.dig(:time_entry, :description).presence
    )
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  def destroy
    authorize @entry
    @entry.destroy!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to card_path(@card) }
    end
  end

  private

  def set_card
    @card = Card.accessible_to(current_user).find(params[:card_id])
  end

  def set_entry
    @entry = TimeEntry.accessible_to(current_user).find(params[:id])
    @card = @entry.card
  end
end
