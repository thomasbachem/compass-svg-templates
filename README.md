Compass SVG Templates
===========================================================================================

Use variables in SVGs to modify images on-the-fly
-------------------------------------------------------------------------------------------

This [Compass](http://compass-style.org) extension can read SVG files, replace variables
in these images (e.g. to manipulate colors) and optionally also render them as PNG images
e.g. for Internet Explorer <= 8.

### Installation

```sh
sudo gem install compass-svg-templates
```

If you want to make use of the PNG rendering functionality as well, you need to have
librsvg, ImageMagick and RMagick installed. You can install those on OS X using
[Homebrew](http://brew.sh) like this:
```sh
brew install librsvg
brew install imagemagick --with-librsvg
sudo ARCHFLAGS="-arch x86_64" gem install rmagick
```

### Usage

To use the extension in your existing Compass project, add the following to your *config.rb* file:
```ruby
require 'svg-templates'
```

To make use of the shipped mixins in addition to the functions, add this to your SCSS file:
```scss
@import 'svg-templates'
```

### Example

SVG template (*img/circle.svg*):
```svg
<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
	<circle stroke="#{$stroke||black}" fill="#{$fill||white}" cx="50" cy="50" r="40" stroke-width="3" />
</svg>
```

SCSS (*scss/styles.scss*):
```scss
.myselector {
  background-image: svg-template('circle.svg', $stroke: red);
}
```

Compiled CSS (*css/styles.css*):
```css
.myselector {
  background-image: url('styles-circle.12345.svg?12345');
}
```

Generated SVG (*css/styles-circle.12345.svg*):
```svg
<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
	<circle stroke="red" fill="white" cx="50" cy="50" r="40" stroke-width="3" />
</svg>
```

### Functions

#### `svg-template($path, $variables...)`

Reads the SVG file from `$path` (relative to Compass' image path), optionally replaces
variables within the SVG, puts the resulting SVG file in the CSS directory and returns
a `url(...)` statement that points there.
  
#### `svg-template-inline($path, $variables...)`

Like `svg-template` but returns the generated SVG inlined as `url('data:...')`.

#### `svg-template-png($path, $variables...)`

Generates the SVG like `svg-template` but uses RMagick/ImageMagick to render it into
a PNG file and returns the `url(...)` statement pointing to that PNG file.

#### `svg-template-png-inline($path, $variables...)`

Like `svg-template-png` but returns the generated PNG inlined as `url('data:...')`.

### Mixins

The shipped mixins do automatically include a PNG fallback.

#### `svg-template-background($path, $variables...)`

```scss
@mixin svg-template-background($path, $variables...) {
  background-image: svg-template-png($path, keywords($variables));
  // Use a second background-image so IE <= 8 won't parse this property
  background-image: svg-template($path, keywords($variables)), none;
}
```

#### `svg-template-background-inline($path, $variables...)`

```scss
@mixin svg-template-background-inline($path, $variables...) {
  background-image: svg-template-png-inline($path, keywords($variables));
  // Use a second background-image so IE <= 8 won't parse this property
  background-image: svg-template-inline($path, keywords($variables)), none;
}
```

### Configuration Settings

#### `$svg-templates-cache-buster` (default: `auto`)

Set this variable to `null` or an empty string to prevent the extension from
appending a cache buster to the query string or provide a static cache buster
value to be used. The default `auto` tells the extension to use the file's
shortened MD5 hash as the cache buster.

#### `$svg-templates-minify` (default: `1`)

Set this variable to `0` to disable automatic SVG minification (stripping of
XML prolog, doctype, comments and redundant whitespace).