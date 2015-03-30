module Sass::Script::Functions

  # Allow to supply variables as keywords or as a map
  declare :svg_template,            [:path], :var_kwargs => true
  declare :svg_template,            [:path, :variables]

  declare :svg_template_inline,     [:path], :var_kwargs => true
  declare :svg_template_inline,     [:path, :variables]
  
  declare :svg_template_png,        [:path], :var_kwargs => true
  declare :svg_template_png,        [:path, :variables]

  declare :svg_template_png_inline, [:path], :var_kwargs => true
  declare :svg_template_png_inline, [:path, :variables]

  def svg_template(path, variables = {})
    real_path = File.join(Compass.configuration.images_path, path.value)

    # Process SVG
    data = read_svg_file(real_path)
    data = replace_svg_variables(data, variables)

    # Generate filename
    css_basepath = Pathname.new(options[:css_filename].to_s).dirname.sub_ext('').to_s
    css_filename = Pathname.new(options[:css_filename].to_s).basename.sub_ext('').to_s
    svg_filename = Pathname.new(real_path).basename.sub_ext('').to_s
    hash         = Digest::MD5.hexdigest(data)[0, 5]
    svg_basename = "#{css_filename}-#{svg_filename}.#{hash}.svg"

    # Write SVG image file
    File.write(css_basepath + '/' + svg_basename, minify_svg_data(data))

    url = handle_cache_buster(svg_basename, hash)
    unquoted_string("url('#{url}')")
  end

  def svg_template_inline(path, variables = {})
    real_path = File.join(Compass.configuration.images_path, path.value)

    # Process SVG
    data = read_svg_file(real_path)
    data = replace_svg_variables(data, variables)
    data = minify_svg_data(data)

    # Inline SVG image
    data = [data].flatten.pack('m').gsub("\n", '')
    url = "data:image/svg+xml;base64,#{data}"
    unquoted_string("url('#{url}')")
  end

  def svg_template_png(path, variables = {})
    real_path = File.join(Compass.configuration.images_path, path.value)

    # Process SVG
    data = read_svg_file(real_path)
    data = replace_svg_variables(data, variables)

    # Generate filename
    css_basepath = Pathname.new(options[:css_filename].to_s).dirname.sub_ext('').to_s
    css_filename = Pathname.new(options[:css_filename].to_s).basename.sub_ext('').to_s
    svg_filename = Pathname.new(real_path).basename.sub_ext('').to_s
    hash         = Digest::MD5.hexdigest(data)[0, 5]
    png_basename = "#{css_filename}-#{svg_filename}.#{hash}.png"

    # Render SVG as PNG image file using ImageMagick
    img = load_svg_image_data(data)
    img.write(css_basepath + '/' + png_basename)
    
    url = handle_cache_buster(png_basename, hash)
    unquoted_string("url('#{url}')")
  end

  def svg_template_png_inline(path, variables = {})
    real_path = File.join(Compass.configuration.images_path, path.value)

    # Process SVG
    data = read_svg_file(real_path)
    data = replace_svg_variables(data, variables)

    # Render SVG as PNG image file using ImageMagick
    img = load_svg_image_data(data)
    data = img.to_blob()

    # Inline SVG image
    data = [data].flatten.pack('m').gsub("\n", '')
    url = "data:image/svg+xml;base64,#{data}"
    unquoted_string("url('#{url}')")
  end

private

  def get_config_setting(name, default = nil)
    # Read config setting from a scoped or global variable
    setting = environment.caller.var(name)
    if setting.nil?
      default
    else
      setting.value
    end
  end
  
  def read_svg_file(real_path)
    if File.readable?(real_path)
      File.open(real_path, "rb") {|io| io.read}
    else
      raise Compass::Error, "File not found or cannot be read: #{real_path}"
    end
  end

  def replace_svg_variables(data, variables)
    # Cast Sass map to hash
    if variables.respond_to?(:to_h)
      variables = variables.to_h
    end

    # Replace variables
    variables.each do |key, value|
      data = data.gsub('#{$' + key.to_s + '}', value.to_s)
    end

    # Replace undefined variables by their defaults or strip them entirely
    data.gsub(/#\{\$[a-z_][a-zA-Z0-9_]*(?:\|\|(.+?))?\}/, '\1')
  end

  def minify_svg_data(data)
    if get_config_setting('svg-templates-minify', 1) == 1
      # Strip XML prolog, as browsers don't need it when a MIME type is specified
      data = data.gsub(/^<\?xml\s.+?\?>/, '')
      # Strip doctype
      data = data.gsub(/^<!DOCTYPE\s.+?>/, '')
      # Strip comments
      data = data.gsub(/<!--.*?-->/, '')
      # Compress consecutive whitespace
      data = data.gsub(/[\s\r\n]+/, ' ')
    else
      data
    end
  end

  def load_svg_image_data(data)
    begin
      require 'RMagick'
    rescue LoadError
      raise Compass::Error, "Please install RMagick to make use of the PNG rendering functionality."
    end
    begin
      Magick::Image.from_blob(data).first
    rescue
      raise Compass::Error, "SVG file #{real_path} cannot be processed – probably invalid?"
    end
  end

  def handle_cache_buster(url, hash)
    cache_buster = get_config_setting('svg-templates-cache-buster', 'auto')
    cache_buster = hash if cache_buster == 'auto'
    cache_buster.to_s.length > 0 ? url + '?' + cache_buster.to_s : url
  end

end