#
# Xyml_element module is for handling a XYML tree data loaded from a XYML format file. See Xyml module
# for detailed information of XYML.
#
# Xyml_elementモジュールは、XYML形式のファイルをロードして得たXYMLツリー構造データを
# 操作するためのモジュールである。XYML形式については、Xymlモジュールのドキュメントを参照してください。
#
#
# == (1) data model
#
# In the APIs provided by this module, only "elements" in XYML tree data are treated as objects.
# and their attribures, related elements such as child elements and texts can be accessed via
# APIs of the elements.
#
# == (1)データモデル
#
# 本モジュールが提供するAPIでは、XYMLツリー構造データのエレメントのみオブジェクトとして扱い、
# その属性や子エレメントなどの関連エレメント、テキストへのアクセス手段がエレメントのAPIとして提供される。
# 
#                           +-- element --------------------+
#                           |                               |
#   access to attributes    |     +-- attributes ----+      |
#   ------------------------+---->|                  |      |
#                           |     +------------------+      |
#                           |                               |
#   access to child nodes   |     +-- child nodes ---+      |
#   ------------------------+---->|                  |      |
#                           |     +------------------+      |
#                           |                               |
#   access to text          |     +-- text -------------+   |   
#   ------------------------+---->|                     |   |
#                           |     +---------------------+   |
#                           |                               |
#   access to parent element|     +-- parent element(*)-+   |
#   ------------------------+---->|                     |   |
#                           |     +---------------------+   |
#                           +-------------------------------+
#   (*) data designating the parent element is attached when XYML tree data is constructed(e.g. file load).
#
# == (2) preparations
#
# In XYML tree data, an element corresponds to a hash which has only one pair of key and value,
# where the key stands for the element name and the value is an array of
# child elements and texts. Note the key must be a symbol.
#
# After a hash representing an element extends this module, we can use the APIs in this module as
# interfaces to the element. If you load XYML tree data from a file by using the methods in Xyml module, 
# such extensions have already been done.
# 
# == (2) 準備
#
# YMLツリー構造データでは、エレメントは、キー・バリュー対が一つだけのハッシュに対応する。
# そのキーが要素名を表し、そのバリューは子エレメントとテキストが要素の配列となる。
#
# このエレメントであるハッシュに本モジュールを拡張させて後、エレメントへのインタフェースとして
# 本モジュールのAPIを利用する。Xymlモジュール内のメソッドを使ってXYMLツリー構造データをファイルから
# ロードした場合には、このような拡張はすでに行われている。
#
# == (3) method names
#
# The name of each method in this module is a seris of three short strings which stands for
# 'operation','object','condition' respectively.
#
# == (3) メソッド名
#
# 本モジュールのメソッド名は、操作(operation)/対象(object)/条件(condition)を表す文字列を
# 順に並べたものになっている。
#
#     .gcfn  -> g(oepration)       cf(object)                   n(condition)
#
#           +-- operation --+  +-- object ---------------+  +-- condition(what designated?) --+
#           | g : get       |  | c : children            |  | n : element name                |
#           | a : add       |  | cf: first child         |  | a : attribute name and value    |
#           | i : insert    |  | sl: self                |  | na: element and attribute       |
#           | d : delete    |  | sp: previous sibling    |  +---------------------------------+
#           | s : set       |  | ss: immediately         |
#           +---------------+  |     succeeding sibling  |
#                              | p : parent              |
#                              | r : root                |
#                              | a : attribute           |
#                              | t : text                |
#                              +-------------------------+
#
# == (4) about usage examples
#
# In he usage examples for each method, it is assumed that the lines of program code shown below have
# already done(see Xyml module).
#
# == (4) 使用例について
#
# メソッドの使用例については、次のプログラムに続けて行われているものとする(Xymlモジュール参照)。
#
#    # aaa.xyml
#    # - a:
#    #   - b: ccc
#    #   - d:
#    #     - e: fff
#    #   - d:
#    #     - e: ggg
#    #     - text
#    #   - h:
#    #     - e: fff
#    xyml_tree=Xyml::Document.new(File.open("aaa.xyml"))
#    #-> [{a:[{b:'ccc'},{d:[{e:'fff'}]},{d:[{e:'ggg'},'text']},{h:[{e:'fff'}]}]}]
#    
module Xyml_element

  # return element's name
  #
  # エレメントの名前を返す。
  def name
    self.keys[0]
  end
  
  
  # get child elements.
  #
  # 子エレメントの取得
  # ==== Return
  # an array of elements.
  #
  # エレメントの配列
  #
  #    xyml_tree.root.gc
  #    #-> [{d:[{e:"fff"}]},{d:[{e:"ggg"}]},{h:[{e:'fff'}]}]
  def gc
    array=Array.new
    self.values[0].each do |child|
      array << child if child.is_a?(Hash) && child.values[0].is_a?(Array)
    end
    array    
  end
  
  # get the first child element.
  #
  # 最初の子エレメントの取得
  # ==== Return
  # an element, or nil if no children
  #
  # エレメント（子エレメントが無い場合は'nil'）
  #
  #    xyml_tree.root.gcf
  #    #-> {d:[{e:'fff'}]}
  def gcf
    self.values[0].each do |child|
      return child if child.is_a?(Hash) && child.values[0].is_a?(Array)
    end
    nil
  end

  # get child elements with the designated name.
  #
  # 指定された名前を持つ子エレメントの取得
  # ==== Args
  # _ename_ :: element name(string or symbol).
  #
  # _ename_ :: エレメント名(文字列もしくはシンボル)
  # ==== Return
  # an array of elements.
  #
  # エレメントの配列
  #
  #    xyml_tree.root.gcn 'd'    #  or xyml_tree.root.gcn :d 
  #    #-> [{d:[{e:"fff"}]},{d:[{e:"ggg"},'text']}]
  def gcn ename
    ename=ename.intern if ename.is_a?(String)
    array=Array.new
    self.values[0].each do |child|
      array << child if child.is_a?(Hash) && child.keys[0]==ename && child.values[0].is_a?(Array)
    end
    array
  end

  # get the first child element with the designated name.
  #
  # 指定された名前を持つ最初の子エレメントの取得
  # ==== Return
  # an element, or nil if no children with the designated name.
  #
  # エレメント（指定された名前の子エレメントが無い場合は'nil'）
  #
  #    xyml_tree.root.gcfn 'd'    #  or xyml_tree.root.gcfn :d
  #    #-> {d:[{e:"fff"}]}
  def gcfn ename
    ename=ename.intern if ename.is_a?(String)
    self.values[0].each do |child|
      return child if child.is_a?(Hash) && child.keys[0]==ename && child.values[0].is_a?(Array)
    end
    nil
  end

  # get child elements with the designated element name and atrribute.
  #
  # 指定された名前と属性を持つ子エレメントの取得
  # ==== Args
  # _ename_ :: element name(string or symbol)
  # _aname_ :: attribute name(string or symbol)
  # _avalue_ :: attribute value
  #
  # _ename_ :: エレメント名(文字列もしくはシンボル)
  # _aname_ :: 属性名(文字列もしくはシンボル)
  # _avalue_ :: 属性値
  # ==== Return
  # an array of elements.
  #
  # エレメントの配列
  #
  #    xyml_tree.root.gcna 'd','e','ggg'
  #    #-> [{d:[{e:"ggg"},'text']}]
  def gcna ename,aname,avalue
    ename=ename.intern if ename.is_a?(String)
    aname=aname.intern if aname.is_a?(String)
    array=Array.new
    self.values[0].each do |child|
      array << child if child.is_a?(Hash) && child.keys[0]==ename && child.values[0].is_a?(Array) && child.ga(aname)==avalue
    end
    array
  end
 
  # get child elements with the designated atrribute.
  #
  # 指定された属性を持つ子エレメントの取得
  # ==== Args
  # _aname_ :: attribute name(string or symbol)
  # _avalue_ :: attribute value
  #
  # _aname_ :: 属性名(文字列もしくはシンボル)
  # _avalue_ :: 属性値
  # ==== Return
  # an array of elements.
  #
  # エレメントの配列
  #
  #    xyml_tree.root.gca 'e','fff'
  #    #-> [{d:[{e:"fff"}]},{h:[{e:"fff"}]}]
  def gca aname,avalue
    aname=aname.intern if aname.is_a?(String)
    array=Array.new
    self.values[0].each do |child|
      array << child if child.is_a?(Hash) && child.values[0].is_a?(Array) && child.ga(aname)==avalue
    end
    array
  end


  # get the first child elements with the designated element name and atrribute.
  #
  # 指定された名前と属性を持つ最初の子エレメントの取得
  # ==== Args
  # _ename_ :: element name(string or symbol)
  # _aname_ :: attribute name(string or symbol)
  # _avalue_ :: attribute value
  #
  # _ename_ :: エレメント名(文字列もしくはシンボル)
  # _aname_ :: 属性名(文字列もしくはシンボル)
  # _avalue_ :: 属性値
  # ==== Return
  # an element, or nil if no children with the designated name and attribute.
  #
  # エレメント（指定された名前と属性の子エレメントが無い場合は'nil'）
  #
  #    xyml_tree.root.gcfna 'd','e','ggg'
  #    #-> {d:[{e:"ggg"},'text']}
  def gcfna ename,aname,avalue
    ename=ename.intern if ename.is_a?(String)
    aname=aname.intern if aname.is_a?(String)
    self.values[0].each do |child|
      return child if child.is_a?(Hash) && child.keys[0]==ename && child.values[0].is_a?(Array) && child.ga(aname)==avalue
    end
    nil
  end

  # get the previous sibling element.
  #
  # 直前のシブリング(兄弟姉妹)エレメントの取得。
  # ==== Return
  # an element, or nil if no previous sibling element. 
  #
  # エレメント（自身が最初の子エレメントの場合は'nil'）
  #
  #    my_element=xyml_tree.root.gcfna 'd','e','ggg'
  #    #-> {d:[{e:"ggg"},'text']}
  #    my_element.gsp
  #    #-> {d:[{e:"fff"}]}
  def gsp
    if parent=self.gp then
      siblings=parent.gc
      #print "#D#xyml_element.rb:gsp:sliblings=";pp siblings
      siblings.each_with_index do |sibling,index|
        if sibling==self then
          if index==0 then
            return nil
          else
            return siblings[index-1]
          end
        end
      end
    end
  end

  # get the immediately succeeding sibling element.
  #
  # 直後のシブリング(兄弟姉妹)エレメントの取得。
  # ==== Return
  # an element, or nil if no next sibling element. 
  #
  # エレメント（自身が最後の子エレメントの場合は'nil'）
  #
  #    my_element=xyml_tree.root.gcfna 'd','e','ggg'
  #    #-> {d:[{e:"ggg"},'text']}
  #    my_element.gss
  #    #-> {h:[{e:"fff"}]}
  def gss
    if parent=self.gp then
      siblings=parent.gc
      #print "#D#xyml_element.rb:gsp:sliblings=";pp siblings
      siblings.each_with_index do |sibling,index|
        if sibling==self then
          if index==siblings.length-1 then
            return nil
          else
            return siblings[index+1]
          end
        end
      end
    end
  end
  
  # add a child.
  #
  # 子エレメントの追加。
  # ==== Args
  # _elm_ :: an element to add(or a hash that can extend Xyml_element module).
  #
  # _elm_ :: 追加するエレメント(もしくは、Xyml_elementモジュールを拡張しうるハッシュ)
  # ==== Return
  # the element added(or nil if Xyml_element module can be extended).
  #
  # 追加されたエレメント(Xyml_elementモジュールを拡張出来ない場合は'nil')
  # ==== Note
  # This method make the input extend Xyml_element module.
  #
  # このメソッドは、入力に対して、Xyml_elemenntモジュールの拡張を実施させる
  # 
  #
  #    my_element=xyml_tree.root.gcfna 'd','e','ggg'
  #    #-> {d:[{e:"ggg"},'text']}
  #    my_element.ac {j:[{e:'kkk'}]}
  #    my_element.gcf
  #    #-> {j:[{e:"kkk"}]}
  def ac elm
    return nil unless elm.is_a?(Hash) and elm.values[0].is_a?(Array)
    elm.extend Xyml_element
    self.values[0].push(elm)
    elm._sp(self)
    elm
  end

  # insert an element as a previous sibling element.
  #
  # 直前のシブリング(兄弟姉妹)エレメントとして、エレメントを挿入
  # ==== Args
  # _elm_ :: an element to insert(or a hash that can extend Xyml_element module).
  #
  # _elm_ :: 挿入するエレメント(もしくは、Xyml_elementモジュールを拡張しうるハッシュ)
  # ==== Note
  # This method make the input extend Xyml_element module.
  #
  # このメソッドは、入力に対して、Xyml_elemenntモジュールの拡張を実施させる
  # 
  #    my_element=xyml_tree.root.gcfna 'd','e','ggg'
  #    #-> {d:[{e:"ggg"},'text']}
  #    my_element.isp {j:[{e:'kkk'}]}
  #    my_element.gsp
  #    #-> {j:[{e:"kkk"}]}
  def isp elm
    return nil if self.gp==:_iamroot
    elm.extend Xyml_element
    parent=self.gp
    parent.values[0].each_with_index do |sibling,index|
      if sibling==self then
        parent.values[0].insert(index,elm)
        elm._sp(parent)
        break
      end
    end
    elm
  end

  # insert an element as an immediately succeeding sibling element.
  #
  # 直後のシブリング(兄弟姉妹)エレメントとして、エレメントを挿入
  # ==== Args
  # _elm_ :: an element to insert(or a hash that can extend Xyml_element module).
  #
  # _elm_ :: 挿入するエレメント(もしくは、Xyml_elementモジュールを拡張しうるハッシュ)
  # ==== Note
  # This method make the input extend Xyml_element module.
  #
  # このメソッドは、入力に対して、Xyml_elemenntモジュールの拡張を実施させる
  # 
  #    my_element=xyml_tree.root.gcfna 'd','e','ggg'
  #    #-> {d:[{e:"ggg"},'text']}
  #    my_element.iss {j:[{e:'kkk'}]}
  #    my_element.gss
  #    #-> {j:[{e:"kkk"}]}
  def iss elm
    return nil if self.gp==:_iamroot
    elm.extend Xyml_element
    parent=self.gp
    parent.values[0].each_with_index do |sibling,index|
      if sibling==self then
        parent.values[0].insert(index+1,elm)
        elm._sp(parent)
        break
      end
    end
    elm
  end

  # get value of attribute with the designated attribute name.
  #
  # 指定された属性名に対する属性値の取得
  # ==== Args
  # _aname_ :: attribute name(string or symbol)
  #
  # _aname_ :: 属性名(文字列もしくはシンボル)
  #
  #    xyml_tree.root.ga(:b)
  #    #-> 'ccc'
  def ga aname
    aname=aname.intern if aname.is_a?(String)
    self.values[0].each do |child|
      return child.values[0] if child.is_a?(Hash) && child.keys[0]==aname && (!child.values[0].is_a?(Hash) || !child.values[0].is_a?(Array))
    end
    nil
  end
  
  # set value to the attribute with the designated attribute name.
  #
  # 指定された属性名に対する属性値の取得
  # ==== Args
  # _aname_ :: attribute name(string or symbol)
  # _avalue_ :: attribute value
  #
  # _aname_ :: 属性名(文字列もしくはシンボル)
  # _avalue_ :: 属性値
  #
  #    xyml_tree.root.sa(:b,'lll')
  #    xyml_tree.root.ga(:b)
  #    #-> 'lll'
  def sa aname,avalue
    aname=aname.intern if aname.is_a?(String)
    return nil if avalue.is_a?(Array) || avalue.is_a?(Hash)
    self.values[0].each_with_index do |child,index|
      if child.is_a?(Hash)
        #p "#D#syml_element.rb:sa:aname=#{aname},avalue=#{avalue},child=#{child}"
        if child.values[0].is_a?(Array) then
          self.values[0].insert(index,Hash[aname,avalue])
          return self.values[0]
        end
        if child.keys[0]==aname && !child.values[0].is_a?(Array) then
          child[aname]=avalue
          return child
        end
      elsif child.is_a?(String) then
        self.values[0].insert(index,Hash[aname,avalue])
        return self.values[0]
      end
    end
    values[0].push Hash[aname,avalue]
  end

  # delete attribute.
  #
  # 指定された属性名に対する属性の削除
  # ==== Args
  # _aname_ :: attribute name(string or symbol)
  #
  # _aname_ :: 属性名(文字列もしくはシンボル)
  #
  #    xyml_tree.root.da(:b)
  #    xyml_tree.root.ga(:b)
  #    #-> nil
  def da aname
    aname=aname.intern if aname.is_a?(String)
    self.values[0].each_with_index do |child,index|
      if child.is_a?(Hash)
        #p "#D#syml_element.rb:sa:aname=#{aname},avalue=#{avalue},child=#{child}"
        if child.values[0].is_a?(Array) then
          return nil
        end
        if child.keys[0]==aname && !child.values[0].is_a?(Array) then
          self.values[0].delete_at(index)
          return child.values[0]
        end
      elsif child.is_a?(String) then
        return nil
      end
    end
    nil
  end
        
  # get text.
  #
  # テキストの取得
  # ==== Args
  # _param_ :: return joined text if omitted. Return the array of parted text if ":raw" is designated.  
  #
  # _param_ :: 省略時は、結合されたテキストを返す。":raw"が指定された場合は、分かち書きされたテキストの配列を返す。
  #
  # ==== Return
  # String (or Array of Strings if :raw is designated as _param_)
  #
  # 文字列 (もしくは、：rawが指定された場合は、文字列の配列)
  #
  #    my_element=xyml_tree.root.gcfna 'd','e','ggg'
  #    #-> {d:[{e:"ggg"},'text']}
  #    my_element.gt
  #    #-> 'text'
  #    my_element.at 'abc'
  #    my_element.gt
  #    #-> 'textabc'
  #    my_element.gt :raw
  #    #-> ['text','abc']
  def gt(param=false)
    array=Array.new
    self.values[0].each do |child|
      unless child.is_a?(Hash) || child.is_a?(Array)
        array.push child
      end
    end
    if param then
      if param==:raw then
        return array
      end
    end
    array.join
  end

  # set text.
  #
  # テキストの設定
  # ==== Args
  # _text_ :: text(or object with the method 'to_s')
  #
  # _text_ :: テキスト(もしくは、'to_s'メソッドを持つオブジェクト)
  #
  #    my_element=xyml_tree.root.gcfna 'd','e','ggg'
  #    #-> {d:[{e:"ggg"},'text']}
  #    my_element.st 'abc'
  #    my_element.gt
  #    #-> 'abc'
  def st value
    #p "#D#xyml_element.rb:st:(1)caller=#{caller[0]}"
    value=value.to_s
    tempArray=Array.new
    self.values[0].each do |child|
      unless child.is_a?(String)
        tempArray.push child
      end
    end
    self[keys[0]]=tempArray
    self.values[0].push value
  end

  # add text.
  #
  # テキストの追加
  # ==== Args
  # _text_ :: text(or object with the method 'to_s')
  #
  # _text_ :: テキスト(もしくは、'to_s'メソッドを持つオブジェクト)
  #
  #    my_element=xyml_tree.root.gcfna 'd','e','ggg'
  #    #-> {d:[{e:"ggg"},'text']}
  #    my_element.at 'abc'
  #    my_element.gt
  #    #-> 'textabc'
  # ==== Note
  # the added text is stored in the added position on the element's array. see 'gt.'
  #
  # 追加されたテキストは、エレメントの配列に追加された位置に格納される。gtメソッド参照。
  def at value
    value=value.to_s
    self.values[0].push value
  end
  
  # set a parent element.
  #
  # 親エレメントの設定
  # ==== Args.
  # _parent_ :: parent element
  #
  # _parent_ :: 親エレメント
  # ==== Note
  # This method is for the Xyml and Xyml_element module development use, not for users. Use 'ac(add child)' instead.
  #
  # このメソッドは、Xyml、および、Xyml_elementモジュールの開発向けのものであり、ユーザ向けではない。
  # ユーザは"ac(add child)"を使用してください。
  def _sp parent
    self._dp
    if self.keys[0]==:_parent then
      self[:__parent]=parent
    else
      self[:_parent]=parent
    end
  end

  # delete a parent element.
  #
  # 親エレメントの削除
  # ==== Note
  # this method is for the Xyml and Xyml_element package development use, not for users.
  #
  # このメソッドは、Xyml、および、Xyml_elementモジュールの開発向けのものであり、ユーザ向けではない。
  def _dp
    (self.keys.size-1).times{|i| self.delete(self.keys[i+1])}
  end
  
  # get the parent element.
  #
  # 親エレメントの取得。
  # ==== Return
  # the parent element, or nil if no parent element.
  #
  # エレメント（もしくは、親エレメントが無い場合、"nil"）
  #
  #    my_element=xyml_tree.root.gcfna 'd','e','ggg'
  #    my_element.gp
  #    #-> {a:[...]}
  def gp
    parent=self.values[1]
    if parent==:_iamroot then
      nil
    else
      parent
    end
  end
  
  # get the root element.
  #
  # ルートエレメントの取得
  # ==== Return
  # the root element, or nil if no root element.
  #
  # エレメント（もしくは、ルートエレメントが無い場合、"nil"）
  #    new_element=Xyml::element_new(:j)
  #    xyml_tree.root.gcfna('d','e','ggg').ac new_element
  #    new_element.gr
  #    #-> {a:[...]}
  def gr
    elm=self
    while true do
      if elm.values[1]==:_iamroot then
        return elm
      elsif elm.values[1]==nil then
        return nil
      end
      elm=elm.values[1]
    end
  end
  
  # if root, return true
  #
  # ルートの場合、trueを返す。
  #     xyml_tree.root.is_root?
  #     #-> true
  #     xyml_tree.root.gcfna('d','e','ggg').is_root?
  #     #-> false
  def is_root?
    self.values[1]==:_iamroot
  end
    
  # delete the self element from the child element array of its parent element.
  #
  # 自身のエレメントを、親エレメントの子エレメント配列から、削除する。
  #
  #    xyml_tree.root.gcfna('d','e','ggg').dsl
  #    #-> [{a:[{b:'ccc'},{d:[{e:'fff'}]},{h:[{e:'fff'}]}]}]
  def dsl
    if parent=self.gp then
      parent.values[0].each_with_index do |child,index|
        if child==self then
          parent.values[0].delete_at(index)
          self._sp(nil)
          return child
        end
      end
      raise "something wrong. parent does not have me as a child."
    end
    nil
  end

=begin  
  # I think this method is not necessary.
  def dc element
    self.values[0].each_with_index do |tchild,index|
      if tchild==element then
        parent.values[0].delete_at(index)
        element._sp(nil)
        return child
      end
    end
    raise "something wrong. parent does not have an element as a child."
    
  end
=end
  

end
