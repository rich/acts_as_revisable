require File.dirname(__FILE__) + '/spec_helper.rb'

describe WithoutScope::ActsAsRevisable, "with single table inheritance" do  
  after(:each) do
    cleanup_db
  end
  
  before(:each) do
    @article = Article.create(:name => 'an article')
    @post = Post.create(:name => 'a post')
  end
  
  describe "after a revision" do
    it "an article has revisions of the right type" do
      @article.revise!
      @article.revisions(true).first.class.should == ArticleRevision
    end
    
    it "a post has revisions of the right type" do
      @post.revise!
      @post.revisions(true).first.class.should == PostRevision
    end
    
    it "can find an article by name" do
      Article.find_by_name('an article').should_not be_nil
    end
    
    it "can find a post by name" do
      Post.find_by_name('a post').should_not be_nil
    end
  end
end