class CasaCasesController < ApplicationController
  before_action :set_casa_case, only: %i[show edit update deactivate reactivate]
  before_action :set_contact_types, only: %i[new edit update create deactivate reactivate]
  before_action :require_organization!
  after_action :verify_authorized

  def index
    authorize CasaCase
    org_cases = current_user.casa_org.casa_cases.includes(:assigned_volunteers)
    @casa_cases = policy_scope(org_cases).includes([:hearing_type, :judge])
    @casa_cases_filter_id = policy(CasaCase).can_see_filters? ? "casa-cases" : ""
    @duties = OtherDuty.where(creator_id: current_user.id)
  end

  def show
    authorize @casa_case

    respond_to do |format|
      format.html {}
      format.csv do
        case_contacts = @casa_case.decorate.case_contacts_ordered_by_occurred_at
        csv = CaseContactsExportCsvService.new(case_contacts).perform
        send_data csv, filename: case_contact_csv_name(case_contacts)
      end
      format.xlsx do
        filename = @casa_case.case_number + "-case-contacts-" + Time.now.strftime("%Y-%m-%d") + ".xlsx"
        response.headers["Content-Disposition"] = "attachment; filename=#{filename}"
      end
    end
  end

  def new
    @casa_case = CasaCase.new(casa_org: current_organization)
    authorize @casa_case
  end

  def edit
    authorize @casa_case
  end

  def create
    @casa_case = CasaCase.new(
      casa_case_params.merge(
        casa_org: current_organization,
        transition_aged_youth: is_transition_aged_youth?(casa_case_params)
      )
    )
    authorize @casa_case

    if @casa_case.save
      respond_to do |format|
        format.html { redirect_to @casa_case, notice: "CASA case was successfully created." }
        format.json { render json: @casa_case, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @casa_case
    original_attributes = @casa_case.full_attributes_hash
    @casa_case.validate_contact_type = true unless current_role == "Volunteer"
    if @casa_case.update_cleaning_contact_types(casa_case_update_params)
      updated_attributes = @casa_case.full_attributes_hash
      changed_attributes_list = CasaCaseChangeService.new(original_attributes, updated_attributes).calculate

      respond_to do |format|
        format.html { redirect_to edit_casa_case_path, notice: "CASA case was successfully updated.#{changed_attributes_list}" }
        format.json { render json: @casa_case, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def deactivate
    authorize @casa_case, :update_case_status?

    if @casa_case.deactivate
      respond_to do |format|
        format.html do
          flash_message = "Case #{@casa_case.case_number} has been deactivated."
          redirect_to edit_casa_case_path(@casa_case), notice: flash_message
        end

        format.json do
          render json: "Case #{@casa_case.case_number} has been deactivated.", status: :ok
        end
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def reactivate
    authorize @casa_case, :update_case_status?

    if @casa_case.reactivate
      respond_to do |format|
        format.html do
          flash_message = "Case #{@casa_case.case_number} has been reactivated."
          redirect_to edit_casa_case_path(@casa_case), notice: flash_message
        end

        format.json do
          render json: "Case #{@casa_case.case_number} has been reactivated.", status: :ok
        end
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  private

  def is_transition_aged_youth?(params)
    # TODO remove this once TAY conversion is done
    params[:birth_month_year_youth] && Date.parse(params[:birth_month_year_youth]) < 14.years.ago
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_casa_case
    @casa_case = current_organization.casa_cases.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    if params[:action] != "show"
      head :not_found
    else
      respond_to do |format|
        format.html { redirect_to casa_cases_path, notice: "Sorry you are not authorized to perform this action." }
      end
    end
  end

  # Only allow a list of trusted parameters through.
  def casa_case_params
    params.require(:casa_case).permit(
      :case_number,
      :birth_month_year_youth,
      :court_report_due_date,
      :hearing_type_id,
      :judge_id,
      court_dates_attributes: [:date]
    )
  end

  # Separate params so only admins can update the case_number
  def casa_case_update_params
    params.require(:casa_case).permit(policy(@casa_case).permitted_attributes)
  end

  def set_contact_types
    @contact_types = ContactType.for_organization(current_organization)
  end

  def case_contact_csv_name(case_contacts)
    casa_case_number = case_contacts&.first&.casa_case&.case_number
    current_date = Time.now.strftime("%Y-%m-%d")

    "#{casa_case_number.nil? ? "" : casa_case_number + "-"}case-contacts-#{current_date}.csv"
  end
end
