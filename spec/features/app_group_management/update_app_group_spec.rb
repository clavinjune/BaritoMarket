require 'rails_helper'

RSpec.feature 'Application Group Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:helm_cluster_template) { create(:helm_cluster_template) }
  let(:admin) { create(:user) }

  before(:each) do
    set_check_user_groups('groups' => [])

    @app_group_a = create(:app_group)
    create(:helm_infrastructure, app_group: @app_group_a, helm_cluster_template: helm_cluster_template)
  end

  describe 'Edit metadata' do
    context 'As Superadmin' do
      before :each do
        set_check_user_groups('groups' => ['barito-superadmin'])
        create(:group, name: 'barito-superadmin')
        create(:app_group_role)

        login_as admin
      end

      scenario 'User can edit the app group metadata', js: true do
        visit root_path
        click_link @app_group_a.name

        expect(page).to have_css("input#app_group_name[value='#{@app_group_a.name}']")

        fill_in 'app_group_name', with: "new_#{@app_group_a.name}"
        find('input#app_group_name').native.send_keys :enter

        expect(page).to have_css("input#app_group_name[value='new_#{@app_group_a.name}']")
      end

      scenario 'User can edit log retention days', js: true do
        visit root_path
        click_link @app_group_a.name

        fill_in 'app_group_log_retention_days', with: '100'
        find('input#app_group_log_retention_days').native.send_keys :enter

        expect(page).to have_css("input#app_group_log_retention_days[value='100']")
      end

      scenario 'User can edit max TPS', js: true do
        visit root_path
        click_link @app_group_a.name

        fill_in 'app_group_helm_infrastructure_max_tps', with: '32850'
        find('input#app_group_helm_infrastructure_max_tps').native.send_keys :enter

        expect(page).to have_css("input#app_group_helm_infrastructure_max_tps[value='32850']")
      end

      scenario 'Should update max_tps value', js: true do
        visit root_path
        click_link @app_group_a.name

        helm_infrastructure = @app_group_a.helm_infrastructure
        helm_infrastructure.update(max_tps: 100)

        fill_in 'app_group_helm_infrastructure_max_tps', with: '200'
        find('input#app_group_helm_infrastructure_max_tps').native.send_keys :enter

        @app_group.reload
        expect(@app_group.max_tps).to eq 200
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with role "owner" or "admin" can edit app groups metadata', js: true do
        create(
          :app_group_user, app_group: @app_group_a, role: create(:app_group_role, :admin),
                           user: user_b
        )

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).to have_css("input#app_group_name[value='#{@app_group_a.name}']")

        fill_in 'app_group_name', with: "new_#{@app_group_a.name}"
        find('input#app_group_name').native.send_keys :enter

        expect(page).to have_css("input#app_group_name[value='new_#{@app_group_a.name}']")
      end

      scenario 'User with role "member" cannot edit the app groups metadata', js: true do
        create(
          :app_group_user, app_group: @app_group_a, role: create(:app_group_role), user: user_b
        )

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).not_to have_css('input#app_group_name')
      end

      scenario 'Log retention days cannot be edited by member' do
        create(
          :app_group_user, app_group: @app_group_a, role: create(:app_group_role), user: user_b
        )

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).not_to have_css('input#app_group_log_retention_days')
      end

      scenario 'Max TPS cannot be edited by member' do
        create(
          :app_group_user, app_group: @app_group_a, role: create(:app_group_role), user: user_b
        )

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).not_to have_css('input#app_group_helm_infrastructure_max_tps')
      end

      scenario 'Log retention days cannot be edited by owner' do
        create(
          :app_group_user, app_group: @app_group_a, role: create(:app_group_role, :owner), user: user_b
        )

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).not_to have_css('input#app_group_log_retention_days')
      end

      scenario 'Max TPS cannot be edited by owner' do
        create(
          :app_group_user, app_group: @app_group_a, role: create(:app_group_role, :owner), user: user_b
        )

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).not_to have_css('input#app_group_helm_infrastructure_max_tps')
      end

      scenario 'Log retention days cannot be edited by admin' do
        create(
          :app_group_user, app_group: @app_group_a, role: create(:app_group_role, :admin), user: user_b
        )

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).not_to have_css('input#app_group_log_retention_days')
      end

      scenario 'Max TPS cannot be edited by admin' do
        create(
          :app_group_user, app_group: @app_group_a, role: create(:app_group_role, :admin), user: user_b
        )

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).not_to have_css('input#app_group_helm_infrastructure_max_tps')
      end
    end
  end
end
