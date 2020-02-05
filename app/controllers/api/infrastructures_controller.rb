# DEPRECATION NOTICE
# This API and all of its inherited APIs will be deprecated in favor of v2
class Api::InfrastructuresController < Api::BaseController

  def profile_by_cluster_name
    @infrastructure = Infrastructure.find_by(
      cluster_name: params[:cluster_name])

    if @infrastructure.blank? || !@infrastructure.active?
      render json: {
        success: false,
        errors: ["Infrastructure not found"],
        code: 404
      }, status: :not_found and return
    end

    render json: {
      name: @infrastructure.name,
      app_group_name: @infrastructure.app_group_name,
      capacity: @infrastructure.capacity,
      cluster_name: @infrastructure.cluster_name,
      consul_host: @infrastructure.consul_host,
      status: @infrastructure.status,
      provisioning_status: @infrastructure.provisioning_status,
      updated_at: @infrastructure.updated_at.strftime(Figaro.env.timestamp_format),
      meta: {
        # TODO: we should store this somewhere
        service_names: {
          producer: 'barito-flow-producer',
          zookeeper: 'zookeeper',
          kafka: 'kafka',
          consumer: 'barito-flow-consumer',
          elasticsearch: 'elasticsearch',
          kibana: 'kibana',
        },
      },
    }
  end

  def profile_curator
    if Figaro.env.es_curator_client_key != params[:client_key]
      render(json: {
               success: false,
               errors: ['Unauthorized'],
               code: 401,
             }, status: :not_found) && return
    end

    profiles = []
    AppGroup.all.each do |app_group|
      next if app_group.infrastructure.provisioning_status != Infrastructure.provisioning_statuses[:finished]

      es_component = app_group.infrastructure.infrastructure_components.where(
        component_type: 'elasticsearch',
        status: InfrastructureComponent.statuses[:finished],
      ).first

      next if es_component == nil

      profiles << {
        ipaddress: es_component.ipaddress,
        log_retention_days: app_group.log_retention_days,
        log_retention_days_per_topic: app_group.barito_apps.inject({}) do |app_map, app|
          app_map[app.topic_name] = app.log_retention_days ? app.log_retention_days : app_group.log_retention_days
          app_map
        end
      }
    end

    render json: profiles
  end

  def authorize_by_username
    @current_user = User.find_by_username_or_email(params[:username])
    @infrastructure = Infrastructure.
      find_by_cluster_name(params[:cluster_name])

    if @current_user.blank? || @infrastructure.blank? || !@infrastructure.active? || !InfrastructurePolicy.new(@current_user, @infrastructure).exists?
      render json: {
        success: false,
        errors: ["Forbidden"],
        code: 403
      }, status: :forbidden and return
    end

    render json: "", status: :ok
  end
end
