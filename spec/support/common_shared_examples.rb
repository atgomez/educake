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

