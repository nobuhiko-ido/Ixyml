require 'rexml/document'
require 'yaml'
require 'json'
require 'pp'
require_relative 'xyml_element'
# In this manual, "XYML" is explained first. After that, "XYML module" is explained.
#
# このマニュアルでは、最初にXYMLについて説明し、その後にXYMLモジュールについて説明する。 
#
# == (1)XYML file format
# I propose an alternative text file format ”XYML(Xml in YaML format)” for writing XML subset data, 
# suitable for input by non-engineers. Although some file formats have been proposed for the same purpose, 
# XYML can be distinguished from them by its significant feature that a XYML format file can be read and 
# written as a YAML file. Inheriting both the simple tree data structure of XML and the readability of YAML,
# a text in the XYML format is easy to understand because it looks like book contents. 
#
# == (1)Xymlファイル形式
#
# 非技術者にも XML サブセットデータの入力が容易に行えることを目的とした、ファイル形式
# ”XYML(Xml in YaML format)”を提案する。このようなファイル形式は既にいくつもの提案があるが、
# 提案する XYML はデータ直列化形式である YAML ファイルとして読み書きが出来ることに大きな特徴がある。
# XML のツリー構造データの簡明さと YAML の可読性の良さとを活かすことにより、目次風の分かりやすい
# ファイル形式を XYML は実現している。
#
#
# == (2)Example of Mapping between XYML and XML
# == (2)XYMLとXMLとの対応の例
#  +--XYML------------+    +--XML---------------+
#  | - aaa:           |    | <aaa>              |
#  |   - bbb:         |    |   <bbb xxx="1"     |
#  |     - xxx: 1     |    |        yyy="2">    |
#  |     - yyy: 2     |    |     <ccc zzz="3">  |
#  |     - ccc:       |    |       morning      |
#  |       - zzz: 3   |    |     </ccc>         |
#  |       - morning  |    |     <ddd zzz="4">  |
#  |     - ddd:       |    |       noon         |
#  |       - zzz: 4   |    |     </ddd>         |
#  |       - noon     |    |   </bbb>           |
#  |   - eee:         |    |   <eee xxx="5"     |
#  |     - xxx: 5     |    |        yyy="6">    |
#  |     - yyy: 6     |    |     <fff zzz="7">  |
#  |     - fff:       |    |       night        |
#  |       - zzz: 7   |    |     </fff>         |
#  |       - night    |    |   </eee>           |
#  +------------------+    | </aaa>             |
#                          +--------------------+
#
# == (3)Mapping from XML to XYML
#
# == (3)XMLからXYMLへの対応付け
#
# === (3.1)element
#
#
# An element corresponds to a hash which has only one pair of key and value,
# where the key stands for the element name and the value is an array of
# child elements and texts. Note the key must be a symbol.
#
#
# === (3.1)要素(エレメント)
#
#
# 要素は、キー・バリュー対が一つだけのハッシュに対応する。そのキーが要素名を
# 表し、そのバリューは子エレメントとテキストが要素の配列となる。要素名となる
# キーはシンボルであることに注意。
#
#  +--XML--------------------+   +--XYML-------+
#  | <eee a>bc</eee>         |   | - eee:      |  '-'(hyphon) before 'eee'
#  | * a   : attribute       |   |   - a       |  stands for a part of array  
#  | * b,c : child node,text |   |   - b       |  that belongs to the parent
#  +-------------------------+   |   - c       |  element.
#                                +-------------+
#
#
# === (3.2)attribute
#
# An attribute corresponds to a hash which has only one pair of key and value,
# where the key stands for the attribute name and the value is a scalar of attribute
# value. 
# A hash of an attribute can be distinguished from a hash of an element by the fact
# that its value is not an array. Note the key must be a symbol.
# 
# === (3.2)属性
#
# 属性は、キー・バリュー対が一つだけのハッシュに対応する。そのキーが属性名を
# 表し、そのバリューが属性値を表す。
# バリューが配列では無いことにより、属性のハッシュは、要素のハッシュと見分けがつく。
# キーはシンボルであることに注意。
#
#  +--XML--------------------+   +--XYML-------+  '-'(hyphon) before 'aaa'
#  | aaa="AAA"               |   | - aaa:  AAA |  stands for a part of array 
#  |                         |   |             |  that belongs to the parent
#  +-------------------------+   +-------------+  element.
#
# === (3.3) text node
#
# A text node corresponds to a scalar which is in the array of its parent element.
#
# If two or more scalars are in the array, they are joined when method 'gt'(get text) is called. 
# You can get such parted text stored in a array when designating :raw for the argument of method 'gt.' 
# see Xyml_element module for 'gt' method
#
# === (3.3) テキストノード
#
# テキストは、親エレメントの配列に直接格納されるスカラーに対応する。
#
# ２つ以上のスカラーが配列内にある場合、エレメントの'gt'メソッドが呼び出された際に、それらは結合
# される。'gt'メソッドの引数に:rawを指定すると、配列に格納された分かち書きのテキストが得られる。
# (メソッド'gt'については、Xyml_elementモジュールを参照のこと)
#
#  +--XML--------------------+   +--XYML-------+  '-'(hyphon) before 'TTT'
#  | <...>TTT<...>           |   | - TTT       |  stands for a part of array 
#  |                         |   |             |  that belongs to the parent
#  +-------------------------+   +-------------+  element.
#
#
#
# ==(4) XYML module
# Xyml module has the following functions:
# * loads a XYML file to an instance of Xyml::Document, saves an instance of Xyml::Document to a XYML file.
# * loads an XML subset file to an instance of Xyml::Document, saves an instance of Xyml::Document to an XML file. 
# * saves an instance of Xyml::Document to a JSON file.(You can load a JSON file as XYML file, because JSON is included in YAML as its flow style.)
# * converts an instance of Xyml::Document to an instance of REXML::Document and vice versa. Note an instance of REXML::Document in this case supports a subset of XML specifications, not full set. 
# Instance methods of Xyml::Document class deal with only accesses to instance variables. Concrete procedures are written in Xyml module methods.
# In the figure below, Xyml module method names are enclosed in square brackets("[]"). 
#
# ==(4) XYMLモジュール
# 提案するファイル形式XYMLについて、Xymlモジュールは次の機能を持つ。
# * Xyml::Documentクラスのインスタンスとして、XYMLファイルをロード／出力する。
# * Xyml::Documentクラスのインスタンスとして、XMLサブセットのファイルをロード／出力する。
# * Xyml::Documentクラスのインスタンスとして、JSONファイルを出力する(JSONはYAMLのフロースタイルなので、入力はXYMLファイルとして行える)。
# * Xyml::DocumentクラスのインスタンスとREXML::Documentのインスタンスとの相互変換を行う(但し、REXML::Documentは仕様のフルセットでなく、サブセットに対応)。
# Xyml::Documentクラスのメソッドは、インスタンス変数に関わる処理のみを行い、具体的な処理はXymlモジュールメソッドに記述している。
# 下図中、モジュールメソッド名は"[]"(角型括弧)で囲んで表示している。
#
#  +-------------------------+  load_XYML     +------------------+
#  |                         |[rawobj2element]|                  |
#  |                         |<---------------|                  |
#  |  Xyml::Document         |  out_XYML      |    XYML file     |
#  |  instance               | [doc2file]     |(YAML subset file)|
#  |                         |--------------->|                  |
#  |  +-------------+        |                +------------------+ 
#  |  |  Raw Object |        |
#  |  +-------------+        |  out_JSON      +------------------+ 
#  |                         |--------------->| JSON subset file |
#  +-------------------------+                +------------------+
#    |                 |  ^
#    |  to_domobj      |  |
#    V [rawobj2domobj] |  |[domboj2element]
#  +-------------------|--|--+
#  |                   |  |  |  load_XML      +------------------+
#  |                   |  +---<---------------|                  |
#  |  REXML::Document  |     |  out_XML       | XML subset file  |
#  |  instance         +--------------------->|                  |
#  |                         |                +------------------+ 
#  +-------------------------+ 
#
#
# see also "Xyml_element module."
#
# 参考：Xyml_elementモジュール
#
module Xyml
  
  # convert a tree composed of alternate hashes and arrays into a XYML element tree.
  #
  # ハッシュと配列とを交互に組み合わせたツリーを、XYMLエレメントのツリーに変換する。
  # ==== Args
  # _rawobj_ :: the root of a tree composed of alternate hashes and arrays
  # ==== Return
  # the root element of a created XYML element tree.
  def self.rawobj2element rawobj
    temp_root=Xyml::Element.new :tempRoot
    Xyml.rawobj2element_rcsv rawobj,temp_root
    temp_root[:tempRoot][0]._sp(:_iamroot)
    temp_root[:tempRoot][0]
  end

  # convert a tree composed of alternate hashes and arrays into XML strings.
  # note that a XYML element tree is such a tree to be converted by this method.
  #
  # ハッシュと配列とを交互に組み合わせたツリーを、XMLの文字列に変換する。
  # XYMLエレメントのツリーも、このメソッドにより変換されるツリーとなっていることに注意。
  # ==== Args
  # _rawobj_ :: the root of a tree composed of alternate hashes and arrays.
  # ==== Return
  # strings in XML.
  def self.rawobj2xmlString rawobj
    sio=StringIO.new
    Xyml.rawobj2domobj(rawobj).write(sio)
    sio.rewind
    sio.read
  end
  
  # convert a tree composed of alternate hashes and arrays into a DOM object tree.
  # note that a XYML element tree is such a tree that can be converted by this method.
  #
  # ハッシュと配列とを交互に組み合わせたツリーを、DOMオブジェクトのツリーに変換する。
  # XYMLエレメントのツリーも、このメソッドにより変換されるツリーとなっていることに注意。
  # ==== Args
  # _rawobj_ :: the root of a tree composed of alternate hashes and arrays.
  #
  # ==== Return
  # an instance of REXML::Document.
  def self.rawobj2domobj rawobj
    dom = REXML::Document.new <<EOS
<?xml version='1.0' encoding='UTF-8'?>
EOS
    Xyml.rawobj2domobj_rcsv rawobj,dom
  end

  # extend each hash in a tree composed of alternate hashes and arrays to a XYML element, and
  # obtain a XYML element tree. This method is similar to _rawobj2element_ method except that _extend_element_
  # does not create new hashes and arrays. In order to apply this method to a tree, 
  # all hashes in that tree must use symbols as hash keys.
  #
  # ハッシュと配列とを交互に組み合わせたツリー中のハッシュをXYMLエレメントに拡張し、
  # XYMLエレメントツリーを得る。このメソッドは、 _rawobj2element_と似ているが、新たにハッシュと配列を
  # 生成しない点が異なっている。このメソッドを適用するツリーでは、ハッシュのキーはすべてシンボルで
  # なければならない。
  # ==== Args
  # _rawobj_ :: the root of a tree composed of alternate hashes and arrays
  # ==== Return
  # the root element of a created XYML element tree, which is identical to _rawobj_ in the input argument.
  def self.extend_element rawobj
    Xyml.extend_element_rcsv rawobj,nil
  end
  
  # convert a DOM object tree into a XYML element tree.
  #
  # DOMオブジェクトのツリーをXYMLエレメントのツリーに変換する。
  # ==== Args
  # _domobj_ :: an instance of REXML::Document.
  # ==== Return
  # the root element of a created XYML element tree.
  #
  # 生成されたXYMLエレメントツリーのルートエレメント
  def self.domobj2element domobj
    temproot=Hash.new
    temproot.extend Xyml_element
    Xyml.domobj2element_rcsv domobj,temproot,nil
  end
  
  # print out a XYML element tree to a XYML file.
  #
  # XYMLエレメントのツリーをXYMLファイルとしてプリントアウトする。
  # ==== Args
  # _doc_ :: an instance of Xyml::Document.
  # _io_ :: output IO.
  def self.doc2file doc,io
    io.print "---\n"
    Xyml.doc2file_rcsv(doc,0,io)

  end
  
  # Indent used in a YAML file. Two spaces.
  #
  # YAMLファイルとしてのインデント。スペース２個。
  Indent='  '
  
  # '- ' : String for sequence(Array) entry in a YAML file.
  #
  # '- ' : YAMLファイルのシーケンス(配列)要素を表す文字列
  SequenceEntry='- '
  
  # ': ' : String for mapping(hash) value in a YAML file.
  #
  # ': ' : YAMLファイルのマッピング(ハッシュ)の値を表す文字列
  MappingValue=': '
  
  # '| ' : String for literal block in a YAML file.
  #
  # '| ' : YAMLファイルのリテラルブロックを表す文字列
  LiteralBlock='| '

  # Xyml::Element class implement the element object in XYML tree data. See Xyml_element module 
  # for more detaled specifications.
  #
  # Xyml::Elementクラスは、XYMLツリーデータ中のエレメントを実装するクラスである。
  # 詳細については、Xyml_elementモジュール参照。
  class Element < Hash
    include Xyml_element
    # create an instance of Xyml::Element class.
    #
    # Xyml::Elementクラスのインスタンスを生成する。
    # ==== Args
    # _name_ :: Element name.
    #
    # _name_ :: エレメント名
    def initialize name
      name=name.intern unless name.is_a?(Symbol)
      self[name]=Array.new
      self
    end
  end
  
  # Xyml::Document class implements the online data loaded from a XYML file.
  # Because XYML is a subset of XML from the viewpoint of data structure, the data in this class
  # is a tree composed of elements, attributes and texts. I call this tree "XYML element tree."
  # The tree data in this class is composed of alternate hashes and arrays, in the same way of 
  # XYML files. See "Xyml module" for the mapping between XYML and XML.
  #
  # Xyml::Documentクラスは、XYMLファイルを読みだしたオンライン上のデータを実装するクラスである。
  # XYMLファイルはデータ構造としてはXMLのサブセットであるため、Xyml::Documentクラスの保持する
  # データは、エレメント・属性・テキストからなるツリーである。これを、XYMLエレメントツリーと呼ぶこととする。
  # XYMLファイルフォーマットと同様に、このクラスによるツリーも、ハッシュと配列との交互の組み合わせ
  # で実現されている。XYMLとXMLとの対応付けについては、"XYMLモジュール"を参照のこと。
  #  +-------------------------+  load_XYML +------------------+
  #  |                         |<-----------|                  |
  #  |  Xyml::Document         |  out_XYML  |    XYML file     |
  #  |  instance               |----------->|(YAML subset file)|
  #  |  +-------------+        |            +------------------+ 
  #  |  |  Raw Object |        |
  #  |  +-------------+        |  out_JSON  +------------------+ 
  #  |                         |----------->| JSON subset file |
  #  +-------------------------+            +------------------+
  #    |                 |  ^
  #    |  to_domobj      |  |
  #    V                 |  | 
  #  +-------------------|--|--+
  #  |                   |  |  |  load_XML +------------------+
  #  |                   |  +---<----------|                  |
  #  |  REXML::Document  |     |  out_XML  | XML subset file  |
  #  |  instance         +---------------->|                  |
  #  |                         |           +------------------+ 
  #  +-------------------------+
  class Document < Array

    # the root of the XYML element tree. This root element is a hash extended by "Xyml_element module," 
    # as all other XYML elements in the tree are also such hashes. The idential element to "@root" is stored
    # in the begining of the array that this class inherites. Threrefore "@root" and "self.at(0)" stand
    # for the same object. @root is provided for accessibility.
    #
    # XYMLエレメントツリーのルート。ツリー中の他のエレメントと同じく、このルートエレメントは
    # "xyml_elementモジュール"により拡張されたハッシュである。@rootと同一のエレメントは、このクラスが
    # 継承する配列の先頭にも格納されている。つまり、"@root"と"self.at(0)"とは同じオブジェクトを指す。
    # "@root"は、アクセスしやすいように設けたものである。
    attr_reader :root
  
    # create an instance of Xyml::Document.
    #
    # Xyml::Documentのインスタンスを生成する。
    # ==== Args
    # if first argument in *_argv_ is designated:
    #
    # *_argv_の第一要素が指定されている場合:
    # - case of a symbol
    # - シンボルの場合
    #   - create an instance composed of only a root element such that the name of the root elemnemt is the first argument
    #   - ルート要素のみからなるインスタンスを生成。ルート要素の名前が、argvの第一要素となる。
    #
    #      xyml_tree=Xyml::Document.new(:a)
    #      #-> [{a:[]}]
    #
    # - case of an IO instance
    # - IOインスタンスの場合
    #   - create an instance corresponding to the XYML file loaded through the IO. note that only XYML file can be loaded, not XML.(use load_XML method to load an XML file.) 
    #   - IOを通してロードしたXYMLファイルに対応したインスタンスを生成する。XYMLファイルのみが指定可能であり、XMLは不可であることに注意。(XMLファイルをロードする場合は、load_XMLメソッドを使用)
    #      # aaa.xyml
    #      #  - a:
    #      #    -b: ccc
    #      #    -d:
    #      #      - eee 
    #      xyml_tree=Xyml::Document.new(File.open("aaa.xyml"))
    #      #-> [{a: [{b: "ccc"},{d: ["eee"]}]}]
    #
    # - case of a tree composed of alternate hashes and arrays.
    # - 交互になったハッシュと配列とにより構成したツリーの場合
    #   - create an instance reflecting a input tree.
    #   - 入力引数のツリーを反映したインスタンスを生成。
    #      xyml_tree=Xyml::Document.new({a: [{b: "ccc"},{d: ["eee"]}]})
    #      #-> [{a: [{b: "ccc"},{d: ["eee"]}]}]
    #      xyml_tree.out_XYML(File.open("aaa.xyml","w"))
    #      #-> aaa.xyml
    #      #  - a:
    #      #    -b: ccc
    #      #    -d:
    #      #      - eee 
    def initialize *argv
      if argv.size==1
        if argv[0].is_a?(Symbol)
          @root=Xyml::Element.new argv[0]
          self.push @root
          @root._sp(:_iamroot)
        elsif argv[0].is_a?(IO)
          raw_yaml=YAML.load(argv[0])
          @root=Xyml.rawobj2element raw_yaml[0]
          self.clear.push @root
          @root._sp(:_iamroot)
        elsif argv[0].is_a?(Hash)
          @root=Xyml.rawobj2element argv[0]
          self.clear.push @root
          @root._sp(:_iamroot)
        end
      elsif argv.size>1
        raise "tried to create Xyml::Document with more than one parameters."
      end
    end
    
    # load an XML file through the designated IO and set the tree data in the file to the self.
    #
    # XMLファイルをIOよりロードして、そのツリーデータを自身に設定する。
    #      # aaa.xml
    #      # <a b="ccc">
    #      #   <d>eee</d>
    #      # </a>
    #      xyml_tree=Xyml::Document.new
    #      xyml_tree.load_XML(File.open("aaa.xml"))
    #      #-> [{a: [{b: "ccc"},{d: ["eee"]}]}]
    def load_XML io
      xml=REXML::Document.new(io)
      @root=Xyml.domobj2element xml.root
      self.clear.push @root
      @root._sp(:_iamroot)
      io.close
    end
    
    # save an XML file corresponding to the tree data in the self through the designated IO.
    #
    # 自身のツリーデータを、指定されたIOを通して、XMLファイルに保存する。
    # ==== Args
    # _indent_(if not nil) :: a saved XML file is formatted with the designaged indent.
    #      xyml_tree=Xyml::Document.new({a: [{b: "ccc"},{d: ["eee"]}]})
    #      #-> [{a: [{b: "ccc"},{d: ["eee"]}]}]
    #      xyml_tree.out_XML(File.open("aaa.xml","w"))
    #      #-> aaa.xml
    #      # <a b="ccc">
    #      #   <d>eee</d>
    #      # </a>
    def out_XML io,indent=nil

      if indent
        Xyml.rawobj2domobj(@root).write(io,indent.to_i)
      else
        sio=StringIO.new
        Xyml.rawobj2domobj(@root).write(sio)
        sio.rewind
        io.print sio.read,"\n"
      end
      io.close
    end
      
    
    # save a XYML file corresponding to the tree data in the self through the designated IO.
    #
    # 自身のツリーデータを、指定されたIOを通して、XYMLファイルに保存する。
    #      xyml_tree=Xyml::Document.new({a: [{b: "ccc"},{d: ["eee","fff"]}]})
    #      #-> [{a: [{b: "ccc"},{d: ["eee","fff"]}]}]
    #      xyml_tree.out_XYML(File.open("aaa.xyml","w"))
    #      #-> aaa.xyml
    #      #  - a:
    #      #    -b: ccc
    #      #    -d:
    #      #      - eee
    #      #      - fff
    def out_XYML io
      Xyml.doc2file(self,io)
      io.close
    end

    # save a XYML file corresponding to the tree data in the self through the designated IO, 
    # in the way that a saved XYML file is in the "standard syle." 
    # For example, a XYML file has no redandant partitions in texts in the "standard style."
    # Two XYML files can be compared presicely if they are in the standard style.
    #
    # 自身のツリーデータを、指定されたIOを通して、"標準スタイル"で、XYMLファイルに保存する。
    # 例えば、"標準スタイル"ではXYMLファイル内で冗長なテキストの分かち書きを行わない。
    # 標準スタイルであれば、２つのファイルを正確に比較することが可能となる。
    #      xyml_tree=Xyml::Document.new({a: [{b: "ccc"},{d: ["eee","fff"]}]})
    #      #-> [{a: [{b: "ccc"},{d: ["eee","fff"]}]}]
    #      xyml_tree.out_XYML(File.open("aaa.xyml","w"))
    #      #-> aaa.xyml
    #      #  - a:
    #      #    -b: ccc
    #      #    -d:
    #      #      - eeefff
    def out_XYML_standard io
      io.print "---\n"
      Xyml.out_xyml_rcsv_std(self,0,io)
      io.close
    end

        
    # load an XYML file through the designated IO and set the tree data in the file to the self.
    #
    # XYMLファイルをIOよりロードして、そのツリーデータを自身に設定する。
    #      # aaa.xyml
    #      #  - a:
    #      #    -b: ccc
    #      #    -d:
    #      #      - eee 
    #      xyml_tree=Xyml::Document.new
    #      xyml_tree.load_XYML(File.open("aaa.xyml"))
    #      #-> [{a: [{b: "ccc"},{d: ["eee"]}]}]
    def load_XYML io
      raw_yaml=YAML.load(io)
      @root=Xyml.rawobj2element raw_yaml[0]
      self.clear.push @root
      io.close
    end
  
    # save a JSON file corresponding to the tree data in the self through the designated IO.
    # Note that a JSON file can be loaded by load_XYML method because JSON is a part of YAML.
    #
    # 自身のツリーデータを、指定されたIOを通して、JSONファイルに保存する。JSONファイルのロードは、
    # _load_XYML_メソッドで実施できることに注意（JSONはYAML仕様の一部分となっているため）。
    #      xyml_tree=Xyml::Document.new({a: [{b: "ccc"},{d: ["eee"]}]})
    #      #-> [{a: [{b: "ccc"},{d: ["eee"]}]}]
    #      xyml_tree.out_JSON(File.open("aaa.json","w"))
    #      #-> aaa.jdon
    #      #  [{"a":[{"b":"ccc"},{"d":["eee"]}]}]
    def out_JSON io
      serialized=JSON.generate(Xyml.remove_parent_rcsv(self)) 
      io.print serialized
      io.close
    end

    # convert the tree data in the self into a REXML::Document instance.
    #
    # 自身のツリーデータを、REXML::Documentインスタンスに変換する。
    # ==== Return
    # a REXML::Document instance.
    #      xyml_tree=Xyml::Document.new({a: [{b: "ccc"},{d: ["eee"]}]})
    #      REXML::Document rexml_tree=xyml_tree.to_domobj
    def to_domobj
      Xyml.rawobj2domobj(@root)
    end

  end # end of Xyml::Document

  private

  def self.rawobj2domobj_rcsv obj,dom
    if obj.is_a?(Hash)
      raise "loaded XYML document is illegal(ruby object contains a hash with no pairs)." if obj.length==0
      raise "loaded XYML document is illegal(ruby object contains a hash where second key is not ':_parent' or ':__parent'). second key=#{obj.keys[1]}" if obj.length>1 && (obj.keys[1]!=:_parent && obj.keys[1]!=:__parent)
      key=obj.keys[0]
      value=obj[key]
      if value.is_a?(Array)
        elm=REXML::Element::new("#{key}")
        dom.add_element(elm)
        if value.length==0
          return
        end
        step=:s0_attribute
        value.each do |tobj|
          case step
            
          when :s0_attribute
            if tobj.is_a?(Hash)
              raise "loaded XYML document is illegal(ruby object contains a hash with no pairs) parent=#{key}." if tobj.length==0
              raise "loaded XYML document is illegal(ruby object contains a hash where second key is not 'parent'). second key=#{tobj.keys[1]}" if tobj.length>1 && (tobj.keys[1]!=:_parent && tobj.keys[1]!=:__parent)
              #puts "class=#{tobj.values[0].class}, to_s=#{tobj.values[0].to_s}"
              if !tobj.values[0].is_a?(Array) && !tobj.values[0].is_a?(Hash)
                elm.attributes["#{tobj.keys[0].to_s}"]="#{tobj.values[0].to_s}"
              else
                step=:s1_others
                redo
              end
            else
              step=:s1_others
              redo
            end
              
          when :s1_others
            if tobj.is_a?(Hash)
              rawobj2domobj_rcsv tobj,elm
            elsif tobj.is_a?(Array)
            else
              elm.add_text(tobj.to_s)
            end
            
          else
          end
        end
      end
    elsif obj.is_a?(Array)
      raise "loaded XYML document is illegal(Array apear on the top)."
    end
    dom
  end

    
  def self.rawobj2element_rcsv(raw_obj,node)
    if raw_obj.is_a?(Hash)
      raise "loaded XYML document is illegal(ruby object contains a hash with no pairs)." if raw_obj.length==0
      raise "loaded XYML document is illegal(ruby object contains a hash with more than one pair). first key=#{obj.keys[0]}" if raw_obj.length>1 
      key=raw_obj.keys[0]
      value=raw_obj[key]
      if value.is_a?(Array)
        elm=Xyml::Element.new("#{key}")
        node.ac elm
        if value.length==0
          return
        end
        step=:s0_attribute
        value.each do |tobj|
          case step
          when :s0_attribute
            if tobj.is_a?(Hash)
              raise "loaded XYML document is illegal(ruby object contains a hash with no pairs) parent=#{key}." if tobj.length==0
              raise "loaded XYML document is illegal(ruby object contains a hash with more than one pair). first key=#{tobj.keys[0]}" if tobj.length>1
              if !tobj.values[0].is_a?(Array) && !tobj.values[0].is_a?(Hash)
                elm.sa tobj.keys[0].to_s.intern,tobj.values[0].to_s
              else
                step=:s1_others
                redo
              end
            else
              step=:s1_others
              redo
            end
           
          when :s1_others
            if tobj.is_a?(Hash)
              rawobj2element_rcsv tobj,elm
            elsif tobj.is_a?(Array)
            else
              elm.at tobj.to_s unless tobj.to_s.empty?
            end
        
          else
          end
        end
      end
    elsif raw_obj.is_a?(Array)
      raise "loaded XYML document is illegal(Array apear on the top)."
    end
    node
  end

  def self.extend_element_rcsv obj,parent
    if obj.is_a?(Hash)
      raise "ruby object is illegal(ruby object contains a hash with no pairs)." if obj.length==0
      raise "ruby object is illegal(ruby object contains a hash with more than one pair). first key=#{obj.keys[0]}" if obj.length>1 
      raise "ruby hash has a key that is not a symbol. keys[0]=#{obj.keys[0]}" unless obj.keys[0].is_a?(Symbol)
      value=obj[obj.keys[0]]
      if value.is_a?(Array)
        value.delete(nil)
        obj.extend Xyml_element
        obj._sp(parent)
        if value.length==0
          return
        end
        step=:s0_attribute
        value.each do |tobj|
          case step
          when :s0_attribute
            if tobj.is_a?(Hash)
              raise "loaded XYML document is illegal(ruby object contains a hash with no pairs) parent=#{key}." if tobj.length==0
              raise "loaded XYML document is illegal(ruby object contains a hash with more than one pair). first key=#{tobj.keys[0]}" if tobj.length>1
               if !tobj.values[0].is_a?(Array) && !tobj.values[0].is_a?(Hash)
                raise "ruby hash has a key that is not a symbol. keys[0]=#{tobj.keys[0]}" unless tobj.keys[0].is_a?(Symbol)
              else
                step=:s1_others
                redo
              end
            else
              step=:s1_others
              redo
            end
           
          when :s1_others
            if tobj.is_a?(Hash)
              extend_element_rcsv tobj,obj
            elsif tobj.is_a?(Array)
            else
            end
        
          else
          end
        end
      end
    elsif obj.is_a?(Array)
      raise "ruby object is illegal(Array apear on the top)."
    end
    obj
  end

  def self.domobj2element_rcsv elm,robj,parent
    if elm.is_a?(REXML::Element)
      elmArray=Array.new
      robj[elm.expanded_name.to_sym]=elmArray
      robj._sp(parent)
      #p "#D#xyml.rb:domobj2element_rcsv:robj:";pp robj
      if elm.has_attributes?
        elm.attributes.each do |key,value|
          attrHash=Hash.new
          attrHash[key.to_sym]=value
          elmArray.push(attrHash)
        end
      end
      elm.each do |node|
        if node.is_a?(REXML::Element)
          elmHash=Hash.new
          elmHash.extend Xyml_element
          domobj2element_rcsv(node,elmHash,robj)
          elmArray.push(elmHash)
        elsif node.is_a?(REXML::Text)
          text=node.to_s.gsub('&lt;','<').gsub('&gt;','>').gsub('&apos;','\'').gsub('&quot;','"').gsub('&amp;','&')
          elmArray.push(text) if text.length!=0
        else
        end
      end
    end
    robj
  end

  def self.doc2file_rcsv obj, nest, io
    if obj.is_a?(Hash)
      key=obj.keys[0]
      value=obj.values[0]
      if value.is_a?(Array) 
        io.print(Indent*nest,SequenceEntry,key.to_s.strip,":\n")
        Xyml.doc2file_rcsv(value,nest+1,io)
      else
        io.print(Indent*nest,SequenceEntry, key.to_s.strip,MappingValue,Xyml.escaped_line(value.to_s),"\n")
      end
    elsif obj.is_a?(Array)
      obj.each do |value|
        if value.is_a?(Hash)
          doc2file_rcsv(value,nest,io,)
        elsif value.is_a?(Array)
        else
          io.print(Indent*nest, SequenceEntry, escaped_line(value.to_s),"\n")
        end
      end
      if obj.length==0
        io.print(Indent*nest,SequenceEntry, "\n")
      end
    else
    end
  end
  
  def self.escaped_line(str)
    escape_needed=false
    if str.match(/\"|[:]\s|\s[#]|\A[,\[\]\{\}#&\*\!\|\>\<\%\s\@:'`]|\A[\?:-]\z|[:]\z|\n/)
      "\""+str.gsub(/\\/,"\\\\\\\\").gsub(/\n/,"\\n").gsub(/\f/,"\\f").gsub(/\"/,'\"')+"\""
    else
      str
    end
  end

  def self.out_xyml_rcsv_std obj, nest, io
    if obj.is_a?(Hash)
      key=obj.keys[0]
      value=obj[key]
      if value.is_a?(Array) 
        io.print(Indent*nest,SequenceEntry,key.to_s.strip,":\n")
        out_xyml_rcsv_std(value,nest+1,io)
      else
        io.print(Indent*nest,SequenceEntry, key.to_s.strip,MappingValue,value.to_s.strip,"\n")
      end
    elsif obj.is_a?(Array)        
      unseparatedString=""
      obj.each do |value|
        if value.is_a?(Hash)
          if unseparatedString.length!=00
            io.print(Indent*nest, SequenceEntry, Xyml.escaped_line(unseparatedString), "\n")
            unseparatedString="";
          end
          Xyml.out_xyml_rcsv_std(value,nest,io,)
        elsif value.is_a?(Array)
        else
          unseparatedString+=value.to_s
        end
      end
      if unseparatedString.length!=0
        io.print(Indent*nest, SequenceEntry, escaped_line(unseparatedString),"\n")
        unseparatedString="";
      end
      if obj.length==0
        io.print(Indent*nest,SequenceEntry, "\n")
      end
    else
    end
  end
  
  
  def self.remove_parent_rcsv elmArray
    raise "something wrong when removing parent information from objects. elmArray=#{elmArray.inspect}" unless elmArray.is_a?(Array)
    elmArray.each do |obj|
      if(obj.is_a?(Hash))
        if(obj.values[0].is_a?(Array))
          obj._dp
          remove_parent_rcsv obj.values[0]
        end
      end
    end
    elmArray
  end

  def self.dbg_dom_print_rcsv elem,nest
      indent="||"
      print "================================\n"
      print indent*nest + "name : #{elem.name}\n"
      attrs = elem.attributes
      attrs.each{|a,e|
        print indent*nest + "attr :#{a}=#{e}\n"
      }
      print indent*nest + "text : \n-->#{elem.text.to_s.gsub("\s",'_').gsub("\t",'\t')}<--\n"
  
      elem.each do |node|
        if node.is_a?(REXML::Element)
          dbg_dom_print_rcsv node,nest+1
        elsif node.is_a?(REXML::Text)
          text=node.to_s.strip
          print indent*nest + "textnode : \n-->#{text.gsub("\s",'_').gsub("\t",'\t')}<--\n"
        end
      end
      
      
      if elem.has_elements? then
        elem.each_element{|e|
           dbg_dom_print_rcsv e,nest+1
        }
      end
  end

      
end
