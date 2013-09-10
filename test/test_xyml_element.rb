require 'test/unit'
require 'shoulda'
require_relative '../lib/ixyml/xyml'

class TestDocument < Test::Unit::TestCase

  fileDir="test/testfiles/"
    
  should ". Xyml_node has same values as correspoinding raw hash and array have." do
    nodeQT=Xyml::Element.new(:questionText)
    #pp nodeQT
    nodeQT.st("textQT")
    nodeQT.sa(:type,"instruction")
    #print "#D#test_xyml_element.rb:nodeQT=";pp nodeQT
    assert_equal(nodeQT[:questionText][1],"textQT")
    assert_equal(nodeQT.gt,"textQT")
    nodeQ=Xyml::Element.new(:question)
    nodeQ.ac(nodeQT)
    assert_equal(nodeQ.gcn(:questionText)[0].gt,"textQT")
    nodeQ.sa(:type,'handWriting')
    assert_equal(nodeQ.ga(:type),'handWriting')
    xyml=Xyml::Document.new(:quizlist)
    xyml.root.ac(nodeQ)
    assert_equal(xyml.root.gcn(:question)[0].ga(:type),'handWriting')
    nodeQ.sa(:type,'handWritingChanged')
    assert_equal('handWritingChanged',nodeQ.ga(:type))
    #print "#D#test_xyml_element.rb:Xyml_node:nodeQ=";pp nodeQ
    nodeQT2=Xyml::Element.new(:questionText)
    nodeQT2.st("textQT2")
    nodeQT2.sa(:type,"choices");
    nodeQ.ac(nodeQT2)
    assert_equal("textQT2",nodeQ.gc[1].gt)
    assert_equal("textQT",nodeQ.gcf.gt)
    assert_equal("textQT",nodeQ.gcfn(:questionText).gt)
    assert_equal("textQT2",nodeQ.gca(:type,"choices")[0].gt)
    assert_equal("textQT2",nodeQ.gcna(:questionText,:type,"choices")[0].gt)
    assert_equal("textQT2",nodeQ.gcfna(:questionText,:type,"choices").gt)
    assert_equal(nodeQ,nodeQT2.gp)
    assert_equal(nodeQT,nodeQT2.gsp)
    assert_equal(nil,nodeQT.gsp)
    assert_equal(nil,nodeQ.gsp)
    assert_equal(nodeQT2,nodeQT.gss)
    assert_equal(nil,nodeQT2.gss)
    assert_equal(nil,nodeQ.gss)
    nodeQT3=Xyml.extend_element({:questionText=>[
                              {:text_type=> "html"},
                              {:task_set => false},
                              {:title => nil},
                              {:instruction => nil},"textQT3"]})
    #nodeQ.icb(nodeQT,nodeQT3)
    nodeQT.isp(nodeQT3)
    #p "#D#test_xyml_element.rb:nodeQ=";pp nodeQ
    assert_equal(nodeQT3,nodeQT.gsp)
    nodeQT4=Xyml.extend_element({:questionText=>[
                              {:text_type=> "text"},
                              {:task_set => false},
                              {:title => nil},
                              {:instruction => nil},"textQT4"]})
    #nodeQ.ica(nodeQT2,nodeQT4)
    nodeQT2.iss(nodeQT4)
    assert_equal(nodeQT4,nodeQT2.gss)
    #pp "#D#test_xyml_element.rb:xyml=";pp xyml
    assert_equal(xyml.root,nodeQT4.gr)
    nodeQT4.da(:task_set)
    assert_equal(nil,nodeQT4.ga(:task_set))
    nodeQT4.dsl
    assert_equal(nil,nodeQT4.gr)
  end

  should ". Created xyml_node can be saved as a xyml file." do
    doc=Xyml::Document.new :quiz
    doc.root.sa(:type,'handWriting')
    elementQuestions=Xyml::Element.new(:questions)
    elementQuestion=Xyml::Element.new(:question)
    elementQuestion.st('who are your?');
    doc.root.ac(elementQuestions)
    elementQuestions.ac(elementQuestion)
    doc.out_XYML(File.open(fileDir+'xymlTemp.xyml','w'))
    docNew=Xyml::Document.new File.open(fileDir+'xymlTemp.xyml','r')
    #docNew=Xyml::Document.new
    #docNew.load_XYML File.open(fileDir+'xymlTemp.xyml','r')
    #print "#D#test_xyml_element.rb:can be saved as xyml:(xyml 1)doc=";pp doc
    #print "#D#test_xyml_element.rb:can be saved as xyml:(xyml 2)docNew=";pp docNew
    assert_equal(doc.inspect,docNew.inspect)
    #print doc.root.gcfn(:questions).to_s
    #print "#D#test_xyml_element.rb:can be saved as xyml:docNew=#{docNew.root.gcfn(:questions).to_s}"
    assert_equal(doc.root.gcfn(:questions).to_s,docNew.root.gcfn(:questions).to_s)
  end

  should ". Created xyml_node can be saved as a xml file." do
    doc=Xyml::Document.new :quiz
    doc.root.sa(:type,'handWriting')
    elementQuestions=Xyml::Element.new(:questions)
    elementQuestion=Xyml::Element.new(:question)
    elementQuestion.st('who are your?');
    doc.root.ac(elementQuestions)
    elementQuestions.ac(elementQuestion)
    doc.out_XML(File.open(fileDir+'xmlTemp.xml','w'))
    docNew=Xyml::Document.new
    docNew.load_XML(File.open(fileDir+'xmlTemp.xml','r'))
    #print "#D#test_xyml_element.rb:can be saved as xml:(1)doc=";pp doc
    #print "#D#test_xyml_element.rb:can be saved as xml:(2)docNew=";pp docNew
    #print open(fileDir+'xmlTemp.xml').read
    assert_equal(doc.inspect,docNew.inspect)
    #print doc.root.gcfn(:questions).to_s
    #print "#D#test_xyml_element.rb:can be saved as xml:(3)docNew.root.gcfn(:questions)=#{docNew.root.gcfn(:questions).to_s}\n"
    #print "#D#test_xyml_element.rb:can be saved as xml:(4)doc.root.gcfn(:questions)=#{doc.root.gcfn(:questions).to_s}\n"
    assert_equal(doc.root.gcfn(:questions).to_s,docNew.root.gcfn(:questions).to_s)
    #print "#D#test_xyml_element.rb:can be saved as xml:(5)docNew.root.gcfn(:questions).gcfn(:question)=#{docNew.root.gcfn(:questions).gcfn(:question).to_s}\n"
    #print "#D#test_xyml_element.rb:can be saved as xml:(6)doc.root.gcfn(:questions).gcfn(:question)=#{doc.root.gcfn(:questions).gcfn(:question).to_s}\n"
    assert_equal(doc.root.gcfn(:questions).gcfn(:question).to_s,docNew.root.gcfn(:questions).gcfn(:question).to_s)
  end

  should ". program samples in the document work correctly." do
    # gc(get children)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    assert_equal(:d,xyml_tree.root.gc[0].name)
    assert_equal('fff',xyml_tree.root.gc[0].ga(:e))
    assert_equal(:d,xyml_tree.root.gc[1].name)
    assert_equal('ggg',xyml_tree.root.gc[1].ga(:e))
    assert_equal(:h,xyml_tree.root.gc[2].name)
    assert_equal('fff',xyml_tree.root.gc[2].ga(:e))
    # gcf(get first child)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    assert_equal(:d,xyml_tree.root.gcf.name)
    assert_equal('fff',xyml_tree.root.gcf.ga(:e))
    # gcn(get child elements with the designated name)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    assert_equal(:d,xyml_tree.root.gcn(:d)[0].name)
    assert_equal('fff',xyml_tree.root.gcn(:d)[0].ga(:e))
    assert_equal(:d,xyml_tree.root.gcn(:d)[1].name)
    assert_equal('ggg',xyml_tree.root.gcn(:d)[1].ga(:e))
    assert_equal(2,xyml_tree.root.gcn(:d).size)
    # gcfn(get the first child element with the designated name)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    assert_equal(:d,xyml_tree.root.gcfn(:d).name)
    assert_equal('fff',xyml_tree.root.gcfn(:d).ga(:e))
    # gcna(get child elements with the designated element name and atrribute)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    assert_equal(:d,xyml_tree.root.gcna(:d,:e,'ggg')[0].name)
    assert_equal('ggg',xyml_tree.root.gcna(:d,:e,'ggg')[0].ga(:e))
    assert_equal(1,xyml_tree.root.gcna(:d,:e,'fff').size)
    # gca(get child elements with the designated atrribute)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    assert_equal(:d,xyml_tree.root.gca(:e,'fff')[0].name)
    assert_equal('fff',xyml_tree.root.gca(:e,'fff')[0].ga(:e))
    assert_equal(:h,xyml_tree.root.gca(:e,'fff')[1].name)
    assert_equal('fff',xyml_tree.root.gca(:e,'fff')[1].ga(:e))
    assert_equal(2,xyml_tree.root.gca(:e,'fff').size)
    # gcfna(get the first child elements with the designated element name and atrribute)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    assert_equal(:d,xyml_tree.root.gcfna(:d,:e,'ggg').name)
    assert_equal('ggg',xyml_tree.root.gcfna(:d,:e,'ggg').ga(:e))
    # gsp(get the previous sibling element)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    my_element=xyml_tree.root.gcfna 'd','e','ggg'
    assert_equal(:d,my_element.gsp.name)
    assert_equal('fff',my_element.gsp.ga(:e))
    # gss(get the immediately succeeding sibling element)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    my_element=xyml_tree.root.gcfna 'd','e','ggg'
    assert_equal(:h,my_element.gss.name)
    assert_equal('fff',my_element.gss.ga(:e))
    # ac(add a child)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    my_element=xyml_tree.root.gcfna 'd','e','ggg'
    my_element.ac({j:[{e:'kkk'}]})
    assert_equal(:j,my_element.gcf.name)
    assert_equal('kkk',my_element.gcf.ga(:e))
    my_element.st(my_element.gt)
    assert_equal('text',my_element[:d][2])
    # isp(insert an element as a previous sibling element)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    my_element=xyml_tree.root.gcfna 'd','e','ggg'
    my_element.isp({j:[{e:'kkk'}]})
    assert_equal(:j,my_element.gsp.name)
    assert_equal('kkk',my_element.gsp.ga(:e))
    # iss(insert an element as an immediately succeeding sibling element)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    my_element=xyml_tree.root.gcfna 'd','e','ggg'
    my_element.iss({j:[{e:'kkk'}]})
    assert_equal(:j,my_element.gss.name)
    assert_equal('kkk',my_element.gss.ga(:e))
    # ga(get value of attribute with the designated attribute name)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    assert_equal('ccc',xyml_tree.root.ga(:b))
    # sa(set value to the attribute with the designated attribute name)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    my_element=xyml_tree.root.gcfna 'd','e','ggg'
    my_element.sa(:e,'lll').sa(:m,'nnn')
    assert_equal('lll',my_element.ga(:e))
    assert_equal('nnn',my_element.ga(:m))
    # da(delete attribute)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    xyml_tree.root.da(:b)
    assert_equal(nil,xyml_tree.root.ga(:b))
    # gt(get text)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    my_element=xyml_tree.root.gcfna 'd','e','ggg'
    assert_equal('text',my_element.gt)
    my_element.at 'abc' 
    assert_equal('textabc',my_element.gt)    
    assert_equal(['text','abc'],my_element.gt(:raw))    
    # st(set text)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    my_element=xyml_tree.root.gcfna 'd','e','ggg'
    my_element.st('abc')
    assert_equal('abc',my_element.gt)
    my_element.st(nil)
    assert_equal('',my_element.gt)
    
    # at(add text)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    my_element=xyml_tree.root.gcfna 'd','e','ggg'
    my_element.at('abc')
    assert_equal('textabc',my_element.gt)
    # gp(get the parent element)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    my_element=xyml_tree.root.gcfna 'd','e','ggg'
    assert_equal(:a,my_element.gp.name)
    assert_equal(nil,xyml_tree.root.gp)
    # gr(get the root element)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    new_element=Xyml::Element.new(:j)
    xyml_tree.root.gcfna('d','e','ggg').ac new_element
    assert_equal(:a,new_element.gr.name)
    # is_root?
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    assert_equal(true,xyml_tree.root.is_root?)
    assert_equal(false,xyml_tree.root.gcfna('d','e','ggg').is_root?)
    # dsl(delete the self element from the child element array of its parent element)
    xyml_tree=Xyml::Document.new({a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]})
    xyml_tree.root.gcfna('d','e','ggg').dsl
    assert_equal(:d,xyml_tree.root.gc[0].name)
    assert_equal('fff',xyml_tree.root.gc[0].ga(:e))
    assert_equal(:h,xyml_tree.root.gc[1].name)
    assert_equal('fff',xyml_tree.root.gc[1].ga(:e))
    assert_equal(2,xyml_tree.root.gc.size)
  end
  
end
