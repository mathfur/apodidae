# -*- encoding: utf-8 -*-

describe Apodidae::Prehtml do
  it "tag(:br)で@valはTag.new('br')オブジェクトとなること" do
    Apodidae::Prehtml.new("tag(:br)").val.should == Apodidae::HtmlTag.new('br')
  end

  it "tag(:p)はTag.new('p')となること" do
    Apodidae::Prehtml.new("tag(:p)").to_html.should == Apodidae::HtmlTag.new('p')
  end

  it "tag(:span){ 'foo' }はTag.new('span', {}, 'foo')" do
    Apodidae::Prehtml.new("tag(:span){ 'foo' }").to_html.should == Apodidae::HtmlTag.new('span', {}, 'foo')
  end
end
