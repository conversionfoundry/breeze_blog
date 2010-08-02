require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper")

describe Breeze::Blog::Comment do
  before :all do
    Breeze::Content::Item.collection.drop
    Breeze::Admin::User.collection.drop
    @root = Breeze::Content::Page.create! :title => "Home", :slug => "", :permalink => "/"
    @blog = Breeze::Blog::Blog.create! :title => "Blog", :parent => @root, :comment_notifications => false
    @user = Breeze::Admin::User.create! :first_name => "Test", :last_name => "Test", :email => "test@example.com"
  end
  
  before :each do
    Breeze::Blog::Post.collection.drop
    Breeze::Blog::Comment.collection.drop
    
    @post = @blog.posts.create! :title => "Blog post", :body => "Test", :author_id => @user.id
  end

  describe "on a blog post" do
    before :each do
      @comment = @post.comments.create! :name => "Test", :email => "test@example.com", :body => "Test"
    end
    
    it "should not be approved automatically" do
      @comment.should be_pending
    end
    
    it "should not increment the post's comment count until published" do
      @post.reload
      @post.comments_count.should be_zero
    end
    
    it "should not increment the post's comment count when deleted unless published" do
      @comment.destroy
      @post.reload
      @post.comments_count.should be_zero
    end
    
    describe "when published" do
      before :each do
        @comment.publish!
        @post.reload
      end
      
      it "should update the post's comment count" do
        @post.comments_count.should == 1
      end
      
      describe "and unpublished" do
        before :each do         
          @comment.spam!
          @post.reload
        end
        
        it "should decrement the post's comment count" do
          @post.comments_count.should be_zero
        end
        
        describe "and deleted" do
          before :each do         
            @comment.destroy
            @post.reload
          end

          it "should not decrement the post's comment count" do
            @post.comments_count.should be_zero
          end
        end
      end
      
      describe "and deleted" do
        before :each do         
          @comment.destroy
          @post.reload
        end
        
        it "should decrement the post's comment count" do
          @post.comments_count.should be_zero
        end
      end
    end
    
    describe "when destroyed" do
      before :each do
        @comment.destroy
        @post.reload
      end
      
      it "should not update the post's comment count" do
        @post.comments_count.should be_zero
      end
    end
  end
end