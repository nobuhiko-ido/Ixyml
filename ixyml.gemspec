# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ixyml/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Nobuhiko Ido"]
  gem.email         = ["ido@gifu-keizai.ac.jp"]
  gem.description   = %q{I propose a new file format called "XYML."  Xyml module has the following functions:
 * loads a XYML file as an instance of Xyml::Document, saves an instance of Xyml::Document as a XYML file.
 * loads an XML subset file as an instance of Xyml::Document, saves an instance of Xyml::Document as an XML file. 
 * saves an instance of Xyml::Document as a JSON file.
 * converts an instance of Xyml::Document to an instance of REXML::Document and vice versa. The instance of REXML::Document supports a subset of XML specifications. 
Xyml_element module provides XYML element API methods. These API methods can be used to elements in Xyml::Document.}
  gem.summary       = %q{XYML file accessors and XYML element accessors.}

  gem.homepage      = "https://github.com/nobuhiko-ido/Ixyml"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ixyml"
  gem.require_paths = ["lib"]
  gem.version       = Ixyml::VERSION
end
