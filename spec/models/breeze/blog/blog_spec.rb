require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper")

describe Breeze::Blog::Blog do
  before :each do
    Breeze::Content::Item.collection.drop
    
    @root = Breeze::Content::Page.create :title => "Home", :slug => "", :permalink => "/"
    @blog = Breeze::Blog::Blog.create :title => "Blog", :parent => @root
  end

  %w(index post archive category tag).each do |v|
    it "should generate a#{:n if v =~ /^[aeiou]/} #{v} view" do
      @blog.views.by_name(v).should_not be_nil
    end
  end
  
  {
    "/blog"                                => :index,
    "/blog/2010"                           => :archive,
    "/blog/2010/7"                         => :archive,
    "/blog/2010/7/27"                      => :archive,
    "/blog/2010/7/27/the-oldest-man-alive" => :post,
    "/blog/category/news"                  => :category,
    "/blog/tag/old"                        => :tag,
    "/blog/tag/old,new"                    => :tag
  }.each_pair do |url, view|
    it "should recognise a request for the #{view} view from #{url}" do
      @blog.view_from_permalink(url).should == @blog.send(:"#{view}_view")
    end
  end
  
  describe "in archive view" do
    it "should provide correct dates for a yearly view" do
      @view = @blog.view_from_permalink("/blog/2010")
      @view.start_date.should == Time.zone.local(2010, 1, 1).to_date
      @view.end_date.should   == Time.zone.local(2010, 12, 31).to_date
    end

    it "should provide correct dates for a monthly view" do
      @view = @blog.view_from_permalink("/blog/2010/7")
      @view.start_date.should == Time.zone.local(2010, 7, 1).to_date
      @view.end_date.should   == Time.zone.local(2010, 7, 31).to_date
    end

    it "should provide correct dates for a daily view" do
      @view = @blog.view_from_permalink("/blog/2010/7/27")
      @view.start_date.should == Time.zone.local(2010, 7, 27).to_date
      @view.end_date.should   == Time.zone.local(2010, 7, 27).to_date
    end
  end
end