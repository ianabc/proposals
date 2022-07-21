require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:person) { create(:person) }
  let(:role) { create(:role, name: 'Staff') }
  let(:user) { create(:user, person: person) }
  let(:location) { create(:location) }
  let(:role_privilege) do
    create(:role_privilege,
           permission_type: "Manage", privilege_name: "Location", role_id: role.id)
  end

  before do
    role_privilege
    user.roles << role
    login_as(user)
  end

  let(:env) { instance_double('env') }

  context 'with a verified user' do
    let(:warden) { instance_double('warden', user: user) }

    before do
      allow_any_instance_of(ApplicationCable::Connection).to receive(:env).and_return(env)
      allow(env).to receive(:[]).with('warden').and_return(warden)
    end

    it "successfully connects" do
      connect "/cable"
      expect(connect.current_user.id).to eq user.id
    end
  end

  context 'without a verified user' do
    let(:warden) { instance_double('warden', user: nil) }

    before do
      allow_any_instance_of(ApplicationCable::Connection).to receive(:env).and_return(env)
      allow(env).to receive(:[]).with('warden').and_return(warden)
    end

    it "rejects connection" do
      expect { connect "/cable" }.to have_rejected_connection
    end
  end
end
