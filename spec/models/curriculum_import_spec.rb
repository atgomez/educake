require 'spec_helper'

describe CurriculumImport do
  describe "#initialize" do
    context "with parameters" do
      let(:import_obj) {CurriculumImport.new(:import_file => "test.csv")}
      it "inits variables" do
        import_obj.import_file.should_not be_blank
      end

      it "validates the attributes" do
        import_obj.valid?.should be_true
      end
    end

    context "with IO object as parameters" do
      let(:csv_file) {fixture_file_upload('/files/curriculums.csv')}
      let(:import_obj) {CurriculumImport.new(:import_file => csv_file)}
      
      it "sets import_file path" do
        import_obj.import_file_path.should be_kind_of(String)
      end

      it "validates the attributes" do
        import_obj.valid?.should be_true
      end
    end

    context "without parameters" do
      let(:import_obj) {CurriculumImport.new}
      it "inits variables" do
        import_obj.import_file.should be_blank
      end

      it "validates the attributes" do
        import_obj.valid?.should be_false
      end
    end

    context "with invalid parameters" do
      let(:png_file) {fixture_file_upload('/files/search.png')}
      let(:import_obj) {CurriculumImport.new(:import_file => png_file)}

      it "validates the attributes" do
        import_obj.valid?.should be_false
      end
    end
  end

  describe "#persisted?" do
    let(:import_obj) {CurriculumImport.new}
    it "is not persisted" do
      import_obj.persisted?.should be_false
    end
  end

  describe ".init_import" do
    it "returns the object" do
      FactoryGirl.create(:curriculum_core)
      obj = CurriculumImport.init_import
      obj.should be_kind_of(CurriculumImport)
      obj.curriculum_core_name.should_not be_blank
    end
  end
end
