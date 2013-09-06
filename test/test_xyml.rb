require 'test/unit'
require 'shoulda'
require_relative '../lib/ixyml/xyml'

class TestDocument < Test::Unit::TestCase

  fileDir="test/testfiles/"
  tempDir="test/dirTemp/"
 
  should ". No differences between loaded xml file and saved xml file" do
    Dir.glob(fileDir+"*.nml.ori.xml") do |fn|
      print "###xml->xml### fn="+fn+"\n"
      xyml=Xyml::Document.new
      fnout=fn.sub(/ori.xml/,'x2x.xml').sub(fileDir,tempDir)
      #p "fn=#{fn},fnout=#{fnout}"
      xyml.load_XML(File.open(fn))
      #p "#D#test_xyml.rb:x2x:loaded dom=";dom_print_rcsv(xyml.get_DOM,0)
      #p "#D#test_xml.rb:xml->xml:xyml=";pp xyml
      xyml.out_XML(File.open(fnout,'w'))
      #p "fnout=#{fnout}"
      #pp open(fnout).readlines
      diff = open(fn).readlines - open(fnout).readlines
      assert_equal([],diff)
      diff = open(fnout).readlines - open(fn).readlines
      assert_equal([],diff)
    end
  end

  should ". No differences between loaded yaml file and saved yaml file" do
    Dir.glob(fileDir+"*.nml.ori.yaml") do |fn|
      print "###yaml->yaml### fn="+fn+"\n"
      xyml=Xyml::Document.new
      fnout=fn.sub(/ori.yaml/,'y2y.yaml').sub(fileDir,tempDir)
      xyml.load_XYML(File.open(fn))
      #p "#D#test_xyml.rb:yaml->yaml:xyml=";pp xyml
      xyml.out_XYML(File.open(fnout,'w'))
      diff = open(fn).readlines - open(fnout).readlines
      diff = diff.find_all {|str| !str.start_with?('#')}
      assert_equal([],diff)
      diff = open(fnout).readlines - open(fn).readlines
      assert_equal([],diff)
    end
  end

  should ". No differences between loaded yaml file and saved yaml -> xml -> yaml file" do
    Dir.glob(fileDir+"*.ori.yaml") do |fn|
      print "###yaml->xml->yaml### fn="+fn+"\n"
      xyml=Xyml::Document.new
      fnoutT=fn.sub(/ori.yaml/,'nml.yaml').sub(fileDir,tempDir)
      fnoutX=fn.sub(/ori.yaml/,'yxy.xml').sub(fileDir,tempDir)
      fnoutY=fn.sub(/ori.yaml/,'yxy.yaml').sub(fileDir,tempDir)
      xyml.load_XYML(File.open(fn))
      #p "#D#tst_xml.rb:yaml->xml->yaml: yaml loaded.";pp xyml
      xyml.out_XYML_standard(File.open(fnoutT,'w'))
      xyml.load_XYML(File.open(fnoutT))
      #p "#D#tst_xml.rb:yaml->xml->yaml: yaml loaded.";pp xyml
      xyml.out_XML(File.open(fnoutX,'w'))
      xyml.load_XML(File.open(fnoutX))
      #p "#D#tst_xml.rb:yaml->xml->yaml: xml loaded.";pp xyml
      xyml.out_XYML(File.open(fnoutY,'w'))
      diff = open(fnoutT).readlines - open(fnoutY).readlines
      assert_equal([],diff)
      diff = open(fnoutY).readlines - open(fnoutT).readlines
      assert_equal([],diff)
    end
  end
  
  should ". No differences between loaded xml file and saved xml -> yaml -> xml file" do
    Dir.glob(fileDir+"*.ori.xml") do |fn|
      print "###xml->yaml->xml### fn="+fn+"\n"
      xyml=Xyml::Document.new
      fnoutT=fn.sub(/ori.xml/,'nml.xml').sub(fileDir,tempDir)
      fnoutX=fn.sub(/ori.xml/,'xyx.xml').sub(fileDir,tempDir)
      fnoutY=fn.sub(/ori.xml/,'xyx.yaml').sub(fileDir,tempDir)
      xyml.load_XML(File.open(fn))
      #pp xyml
      xyml.out_XML(File.open(fnoutT,'w'))
      xyml.load_XML(File.open(fnoutT))
      #p "#D#test_xyml.rb:xml->yaml->xml: xml loaded.fn=#{fnoutT}";pp xyml
      xyml.out_XYML(File.open(fnoutY,'w'))
      xyml.load_XYML(File.open(fnoutY))
      #p "#D#test_xyml.rb:xml->yaml->xml: yaml loaded.fn=#{fnoutY}";pp xyml
      xyml.out_XML(File.open(fnoutX,'w'))
      diff = open(fnoutT).readlines - open(fnoutX).readlines
      assert_equal([],diff)
      diff = open(fnoutX).readlines - open(fnoutT).readlines
      assert_equal([],diff)
    end
  end

  should ". No differences between json file transfered from xml file and json file transfered from yaml file." do
    Dir.glob(fileDir+"*.ori.xml") do |fn|
      print "###xml->json,xml->yaml->json### fn="+fn+"\n"
      xyml=Xyml::Document.new
      fnoutT=fn.sub(/ori.xml/,'nml.xml').sub(fileDir,tempDir)
      fnoutY=fn.sub(/ori.xml/,'xyj.yaml').sub(fileDir,tempDir)
      fnoutXJ=fn.sub(/ori.xml/,'x2j.json').sub(fileDir,tempDir)
      fnoutYJ=fn.sub(/ori.xml/,'y2j.json').sub(fileDir,tempDir)
      xyml.load_XML(File.open(fn))
      #pp xyml
      xyml.out_XML(File.open(fnoutT,'w'))
      xyml.load_XML(File.open(fnoutT))
      #p "#D#test_xyml.rb:xml->yaml->json: xml loaded.fn=#{fnoutY}";pp xyml
      xyml.out_JSON(File.open(fnoutXJ,'w'))
      xyml.out_XYML(File.open(fnoutY,'w'))
      xyml.load_XYML(File.open(fnoutY))
      #p "#D#test_xyml.rb:xml->yaml->json: yaml loaded.fn=#{fnoutY}";pp xyml
      # order of array elements in ruby objects changed from order in yaml. ???? 
      xyml.out_JSON(File.open(fnoutYJ,'w'))
      diff = open(fnoutXJ).readlines - open(fnoutYJ).readlines
      assert_equal([],diff)
      diff = open(fnoutYJ).readlines - open(fnoutXJ).readlines
      assert_equal([],diff)
    end
  end

  should ". No differences between loaded json file and saved json file" do
    Dir.glob(fileDir+"*.nml.ori.json") do |fn|
      print "###json->json### fn="+fn+"\n"
      xyml=Xyml::Document.new
      fnout=fn.sub(/ori.json/,'j2j.json').sub(fileDir,tempDir)
      #p "fn=#{fn},fnout=#{fnout}"
      xyml.load_XYML(File.open(fn))
      #p "#D#test_xyml.rb:x2x:loaded dom=";dom_print_rcsv(xyml.get_DOM,0)
      #p "#D#test_xml.rb:xml->xml:xyml=";pp xyml
      xyml.out_JSON(File.open(fnout,'w'))
      #p "fnout=#{fnout}"
      #pp open(fnout).readlines
      diff = open(fn).readlines - open(fnout).readlines
      assert_equal([],diff)
      diff = open(fnout).readlines - open(fn).readlines
      assert_equal([],diff)
    end
  end


  private

  Indent="||"
  
  def dom_print_rcsv elem,nest
      print "================================\n"
      print Indent*nest + "name : #{elem.name}\n"
      attrs = elem.attributes
      attrs.each{|a,e|
        print Indent*nest + "attr :#{a}=#{e}\n"
      }
      print Indent*nest + "text : \n-->#{elem.text.to_s.gsub("\s",'_').gsub("\t",'\t')}<--\n"

      elem.each do |node|
        if node.is_a?(REXML::Element)
          dom_print_rcsv node,nest+1
        elsif node.is_a?(REXML::Text)
          text=node.to_s
          print Indent*nest + "textnode : \n-->#{text.gsub("\s",'_').gsub("\t",'\t')}<--\n"
        end
      end
      
      
      #if elem.has_elements? then
      #  elem.each_element{|e|
      #     dom_print_rcsv e,nest+1
      #  }
      #end
  end

end
