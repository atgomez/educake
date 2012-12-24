shared_examples_for "paging_exact_page_size" do |obj, params|
  it "returns result with exactly page size" do
    result = obj.load_data(params)
    result.size.should eq(params[:page_size])
  end
end

shared_examples_for "paging_less_than_or_equal_page_size" do |obj, params|
  it "returns result with exactly page size" do
    result = obj.load_data(params)
    (result.size <= params[:page_size]).should be_true
  end
end

# Usage:
# describe "GET 'index" do
#   subject { get :index }
#   include_examples "unauthorized"
# end
#
# You can also specify the unauthorized_user:
# describe "GET 'index" do
#   subject { get :index }
#   let(:unauthorized_user) {FactoryGirl.create(:teacher)}
#   include_examples "unauthorized"
# end
#
shared_examples_for "unauthorized" do
  context "unauthorized" do
    context "not login" do
      it "redirects to login page" do
        subject.should redirect_to new_user_session_path
      end
    end

    context "login with unauthorized account" do
      before(:each) do
        unauthorized_user ||= FactoryGirl.create(:parent)
        sign_in unauthorized_user
      end

      it "shows 'unauthorized' error" do
        subject.response_code.should == 403
      end
    end
  end
end
