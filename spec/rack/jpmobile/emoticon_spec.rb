# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), '../../rack_helper.rb')

describe "絵文字が" do
  include Rack::Test::Methods
  include Jpmobile::RackHelper

  before(:each) do
    @docomo_cr          = "&#xE63E;";
    @docomo_utf8        = [0xe63e].pack("U")
    @docomo_docomopoint = "&#xE6D5;"

    @au_cr              = "&#xE488;"
    @au_utf8            = [0xe488].pack("U")

    @softbank_cr        = "&#xF04A;"
    @softbank_utf8      = [0xf04a].pack("U")
  end

  context "PC のとき" do
    before(:each) do
      @res = Rack::MockRequest.env_for("/")
    end

    it "docomo 絵文字が変換されないこと" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_cr))).call(@res)[2]
      body.should == @docomo_cr
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      body.should == @docomo_utf8
    end

    it "au 絵文字が変換されないこと" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      body.should == @au_cr
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      body.should == @au_utf8
    end

    it "softbank 絵文字が変換されないこと" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      body.should == @softbank_cr
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      body.should == @softbank_utf8
    end
  end

  context "docomo のとき" do
    before(:each) do
      @res = Rack::MockRequest.env_for(
        "/",
        'HTTP_USER_AGENT' => "DoCoMo/2.0 SH902i(c100;TB;W24H12)")
    end

    it "docomo 絵文字が変換されること" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_cr))).call(@res)[2]
      body.should == sjis("\xf8\x9f")
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      body.should == sjis("\xf8\x9f")

      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_docomopoint))).call(@res)[2]
      body.should == sjis("\xf9\x79")
    end

    it "au 絵文字が変換されること" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      body.should == sjis("\xf8\x9f")
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      body.should == sjis("\xf8\x9f")
    end

    it "softbank 絵文字が変換されること" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      body.should == sjis("\xf8\x9f")
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      body.should == sjis("\xf8\x9f")
    end

    it "パラメータが変換されること" do
      query_string = "q=" + URI.encode(sjis("\xf8\x9f"))

      res = Rack::MockRequest.env_for(
        "/?#{query_string}",
        "REQUEST_METHOD" => "GET",
        'HTTP_USER_AGENT' => 'DoCoMo/2.0 SH906i(c100;TB;W24H16)')
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      req.params['q'].should == "\xee\x98\xbe"
      res[2].should == sjis("\xf8\x9f")
    end
  end

  context "au のとき" do
    before(:each) do
      @res = Rack::MockRequest.env_for(
        "/",
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0")
    end

    it "docomo 絵文字が変換されること" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_cr))).call(@res)[2]
      body.should == sjis("\xf6\x60")
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      body.should == sjis("\xf6\x60")

      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_docomopoint))).call(@res)[2]
      body.should == to_sjis("［ドコモポイント］")
    end

    it "au 絵文字が変換されること" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      body.should == sjis("\xf6\x60")
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      body.should == sjis("\xf6\x60")
    end

    it "softbank 絵文字が変換されること" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      body.should == sjis("\xf6\x60")
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      body.should == sjis("\xf6\x60")
    end

    it "パラメータが変換されること" do
      query_string = "q=" + URI.encode(sjis("\xf6\x60"))

      res = Rack::MockRequest.env_for(
        "/?#{query_string}",
        "REQUEST_METHOD" => "GET",
        'HTTP_USER_AGENT' => "KDDI-CA32 UP.Browser/6.2.0.7.3.129 (GUI) MMP/2.0")
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      req.params['q'].should == [0xe488].pack("U")
      res[2].should == sjis("\xf6\x60")
    end
  end

  context "softbank のとき" do
    before(:each) do
      @res = Rack::MockRequest.env_for(
        "/",
        'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
    end

    it "docomo 絵文字が変換されること" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_cr))).call(@res)[2]
      body.should == "\e$Gj\x0f"
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_utf8))).call(@res)[2]
      body.should == "\e$Gj\x0f"

      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@docomo_docomopoint))).call(@res)[2]
      body.should == "［ドコモポイント］"
    end

    it "au 絵文字が変換されること" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_cr))).call(@res)[2]
      body.should == "\e$Gj\x0f"
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@au_utf8))).call(@res)[2]
      body.should == "\e$Gj\x0f"
    end

    it "softbank 絵文字が変換されること" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      body.should == "\e$Gj\x0f"
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      body.should == "\e$Gj\x0f"
    end

    it "パラメータが変換されること" do
      query_string = "q=" + URI.encode([0xe04A].pack("U"))

      res = Rack::MockRequest.env_for(
        "/?#{query_string}",
        "REQUEST_METHOD" => "GET",
        'HTTP_USER_AGENT' => "SoftBank/1.0/910T/TJ001/SN000000000000000 Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      req.params['q'].should == [0xf04a].pack("U")
      res[2].should == "\e$Gj\x0f"
    end
  end

  context "Vodafone のとき" do
    before(:each) do
      @res = Rack::MockRequest.env_for(
        "/",
        'HTTP_USER_AGENT' => "Vodafone/1.0/V705SH/SHJ001/SN000000000000000 Browser/VF-NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
    end

    it "softbank 絵文字が変換されること" do
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_cr))).call(@res)[2]
      body.should == "\e$Gj\x0f"
      body = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::Filter.new(UnitApplication.new(@softbank_utf8))).call(@res)[2]
      body.should == "\e$Gj\x0f"
    end

    it "パラメータが変換されること" do
      query_string = "q=" + URI.encode([0xe04A].pack("U"))

      res = Rack::MockRequest.env_for(
        "/?#{query_string}",
        "REQUEST_METHOD" => "GET",
        'HTTP_USER_AGENT' => "Vodafone/1.0/V705SH/SHJ001/SN000000000000000 Browser/VF-NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1")
      res = Jpmobile::Rack::MobileCarrier.new(Jpmobile::Rack::ParamsFilter.new(Jpmobile::Rack::Filter.new(RenderParamApp.new))).call(res)
      req = Rack::Request.new(res[1])
      req.params['q'].should == [0xf04a].pack("U")
      res[2].should == "\e$Gj\x0f"
    end
  end
end