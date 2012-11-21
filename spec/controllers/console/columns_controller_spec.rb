require File.expand_path('spec/spec_helper')

describe Console::ColumnsController do
  describe "article filter by column" do
    before(:each) do
      @staff = Factory.create(:staff)
      @article = Factory.create(:article, :status => Article::PUBLISHED)
      @root_column = Factory.create(:root_column)
      @children_column = Factory.create(:children_column, :parent_id => @root_column.id)
      @children_column.articles << @article
    end

    it "when the channle is a children column" do
      get :show, {:id => @children_column.id}, {:staff => @staff}
      assigns(:column).should == @root_column
      assigns(:sub_columns).should == [@children_column]
      assigns(:articles).to_a.should == [@article]
    end

    it "when the column is a root channel" do
      get :show, {:id => @root_column.id}, {:staff => @staff}
      assigns(:column).should == @root_column
      assigns(:sub_columns).should == [@children_column]
      assigns(:articles).should == [@article]
    end
  end
end
