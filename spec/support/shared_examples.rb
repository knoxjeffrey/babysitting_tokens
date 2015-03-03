shared_examples "require_sign_in" do
  it "redirects to the root path" do
    clear_current_user
    action
    expect(response).to redirect_to root_path
  end
end