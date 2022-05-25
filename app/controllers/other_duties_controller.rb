class OtherDutiesController < ApplicationController
  before_action :set_other_duty, except: [:new, :create]
  before_action :convert_duration_minutes, only: [:update, :create]

  def new
    @other_duty = OtherDuty.new
  end

  def create
    @other_duty = OtherDuty.new(other_duty_params)

    if @other_duty.save
      redirect_to casa_cases_path, notice: "Duty was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @other_duty.update(other_duty_params)
      redirect_to casa_cases_path, notice: "Duty was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def convert_duration_minutes
    duration_hours = params[:other_duty][:duration_hours].to_i
    converted_duration_hours = duration_hours * 60
    duration_minutes = params[:other_duty][:duration_minutes].to_i
    params[:other_duty][:duration_minutes] = (converted_duration_hours + duration_minutes).to_s
  end

  def other_duty_params
    params.require(:other_duty).permit(:occurred_at, :creator_type, :duration_minutes, :notes).merge({creator_id: current_user.id})
  end

  def set_other_duty
    @other_duty = OtherDuty.find(params[:id])
  end
end
