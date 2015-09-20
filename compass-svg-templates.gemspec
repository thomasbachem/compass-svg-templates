Gem::Specification.new do |spec|
  spec.name          = "compass-svg-templates"
  spec.version       = "1.0.3"
  spec.authors       = ["Thomas Bachem"]
  spec.email         = ["mail@thomasbachem.com"]
  spec.summary       = "Use variables in SVG files to modify CSS images on-the-fly"
  spec.description   = "This Compass extension can read SVG files, replace variables in these images (e.g. to manipulate colors) and optionally render them as PNG images."
  spec.homepage      = "http://github.com/thomasbachem/compass-svg-templates"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "stylesheets/**/*", "README*", "LICENSE*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "sass"
  spec.add_dependency "compass"
  # Make rmagick/ImageMagick optional for now, as it's only required for PNG rendering
  #spec.add_dependency "rmagick"
end
