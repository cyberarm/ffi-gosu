module Gosu
  class Image
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    attach_function :_create_image,      :Gosu_Image_create,     [:string, :uint32], :pointer
    attach_function :_destroy_image,     :Gosu_Image_destroy,    [:pointer],         :void

    attach_function :_create_image_from_markup, :Gosu_Image_create_from_markup,   [:string, :string, :double, :int, :double, :uint32, :uint32, :uint32], :pointer
    attach_function :_create_image_from_text,   :Gosu_Image_create_from_text,     [:string, :string, :double, :int, :double, :uint32, :uint32, :uint32], :pointer
    attach_function :_create_image_from_blob,   :Gosu_Image_create_from_blob,     [:pointer, :int, :int, :int, :uint32],                                 :pointer
    attach_function :_image_subimage,           :Gosu_Image_create_from_subimage, [:pointer, :int, :int, :int, :int],                                    :pointer
    attach_function :_image_load_tiles,         :Gosu_Image_create_from_tiles,    [:pointer, :int, :int, :pointer, :int, :uint32],                       :void

    attach_function :_image_width,       :Gosu_Image_width,      [:pointer], :int
    attach_function :_image_height,      :Gosu_Image_height,     [:pointer], :int

    attach_function :_image_draw,         :Gosu_Image_draw,         [:pointer, :double, :double, :double, :double, :double, :uint32, :uint32], :void
    attach_function :_image_draw_rot,     :Gosu_Image_draw_rot,     [:pointer, :double, :double, :double, :double, :double, :double,
                                                                     :double, :double, :uint32, :uint32],                                      :void
    attach_function :_image_draw_as_quad, :Gosu_Image_draw_as_quad, [:pointer, :double, :double, :uint32, :double, :double, :uint32,
                                                                     :double, :double, :uint32, :double, :double, :uint32, :double, :uint32],  :void

    attach_function :_image_save,        :Gosu_Image_save,        [:pointer, :string],              :void
    attach_function :_image_to_blob,     :Gosu_Image_to_blob,     [:pointer],                       :pointer
    attach_function :_image_insert,      :Gosu_Image_insert,      [:pointer, :pointer, :int, :int], :pointer
    attach_function :_image_gl_tex_info, :Gosu_Image_gl_tex_info, [:pointer],                       :pointer

    def self.from_text(markup, line_height, font: Gosu.default_font_name, width: -1, spacing: 0, align: :left,
                       bold: false, italic: false, underline: false, retro: false)
      Gosu::Image.new( _create_image_from_markup(markup, font, line_height, width, spacing,
                      Gosu.font_alignment_flags(align), Gosu.font_flags(bold, italic, underline), Gosu.image_flags(retro: retro)) )
    end

    def self.from_markup(markup, line_height, font: Gosu.default_font_name, width: -1, spacing: 0, align: :left,
                       bold: false, italic: false, underline: false, retro: false)
      Gosu::Image.new( _create_image_from_markup(markup, font, line_height, width, spacing,
                      Gosu.font_alignment_flags(align), Gosu.font_flags(bold, italic, underline), Gosu.image_flags(retro: retro)) )
    end

    def self.load_tiles(filename, tile_width ,tile_height, retro: false, tileable: false)
      flags = Gosu.image_flags(retro: retro, tileable: tileable)

      tiles_x, tiles_y = 0, 0
      bmp = Gosu::Image.new(filename)

      if (tile_width > 0)
        tiles_x = bmp.width / tile_width
      else
        tiles_x = -tile_width;
        tile_width = bmp.width / tiles_x
      end

      if (tile_height > 0)
        tiles_y = bmp.height / tile_height
      else
        tiles_y = -tile_height;
        tile_height = bmp.height / tiles_y
      end

      array_size = tiles_x * tiles_y
      buffer = FFI::MemoryPointer.new(:pointer, array_size)
      _image_load_tiles(filename, tile_width, tile_width, buffer, array_size, flags)

      images = []
      # buffer points to the 0th array index
      # need to read the pointer at that location to
      # get pointer of Gosu::Image
      array_size.times do |i|
        ptr = FFI::Pointer.new(buffer.address + i * Fiddle::SIZEOF_VOIDP).read_pointer
        images << Gosu::Image.new(ptr, retro: retro, tileable: tileable)
      end

      return images
    end

    def initialize(object, retro: false, tileable: false)
      if object.is_a?(String)
        @__image = _create_image(object, Gosu.image_flags(retro: retro, tileable: tileable))

      elsif object.is_a?(FFI::Pointer)
        @__image = object
      elsif object.respond_to?(:to_blob) &&
            object.respond_to?(:columns)
            object.respond_to?(:rows)

        blob_bytes = object.to_blob { self.format = 'RGBA'; self.depth = 8 }.bytes
        FFI::MemoryPointer.new(:uchar, blob_bytes.size) do |blob|
          blob.write_array_of_type(:uchar, :put_uchar, blob_bytes)
          @__image = _create_image_from_blob(blob, blob_bytes.size, object.columns, object.rows, Gosu.image_flags(retro: retro))
        end

        raise "Failed to load image from blob" if @__image.null?
      else
        pp object
        raise ArgumentError
      end

      raise RuntimeError unless @__image
    end

    def __pointer
      @__image
    end

    def width
      _image_width(@__image)
    end

    def height
      _image_height(@__image)
    end

    def draw(x, y, z, scale_x = 1, scale_y = 1, color = Gosu::Color::WHITE, flags = :default)
      _image_draw(@__image, x, y, z, scale_x, scale_y, Gosu.color_to_drawop(color), Gosu.blendmode(flags))
    end

    def draw_rot(x, y, z, angle, center_x = 0.5, center_y = 0.5, scale_x = 1, scale_y = 1, color = Gosu::Color::WHITE, flags = :default)
      _image_draw_rot(@__image, x, y, z, angle, center_x, center_y, scale_x, scale_y, Gosu.color_to_drawop(color), Gosu.blendmode(flags))
    end

    def draw_as_quad(x1, y1, color1, x2, y2, color2, x3, y3, color3, x4, y4, color4, z = 0, mode = :default)
      _image_draw_as_quad(x1, y1, Gosu.color_to_drawop(color1), x2, y2, Gosu.color_to_drawop(color2),
                          x3, y3, Gosu.color_to_drawop(color3), x4, y4, Gosu.color_to_drawop(color4),
                          z, Gosu.blendmode(mode))
    end

    def save(filename)
      _image_save(@__image, filename)
    end

    def to_blob
      _image_to_blob(@__image).read_string(width * height * Gosu::Color::SIZEOF)
    end

    def subimage(left, top, width, height)
      Gosu::Image.new( _image_subimage(@__image, left, top, width, height) )
    end

    def insert(image, x, y)
      image_ = nil
      if image.is_a?(Gosu::Image)
        image_ = image_.__pointer
      elsif image.respond_to?(:to_blob) &&
            image.respond_to?(:rows) &&
            image.respond_to?(:columns)
        image_ = Gosu::Image.new(image).__pointer
      else
        raise "Unable to insert image!"
      end

      _image_insert(@__image, image_, x, y)
    end

    def gl_tex_info
      tex_info = _image_gl_tex_info(@__image)
      tex_info ? GLTexInfo.new(tex_info) : nil
    end

    # TODO: investigate if/how to have ruby's GC handle this
    def free_object
      _destroy_image(@__image)
    end
  end
end