require 'svg-templates/sass_extensions'

extension_path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
Compass::Frameworks.register('svg-templates', :path => extension_path)