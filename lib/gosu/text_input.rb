module Gosu
  class TextInput
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    attach_function :_create_textinput,   :Gosu_TextInput_create,   [],         :pointer
    attach_function :_destroy_textinput,  :Gosu_TextInput_destroy,  [:pointer], :void

    attach_function :_textinput_caret_pos,            :Gosu_TextInput_caret_pos,           [:pointer],          :uint32
    attach_function :_textinput_set_caret_pos,        :Gosu_TextInput_set_caret_pos,       [:pointer, :uint32], :void
    attach_function :_textinput_selection_start,      :Gosu_TextInput_selection_start,     [:pointer],          :uint32
    attach_function :_textinput_set_selection_start,  :Gosu_TextInput_set_selection_start, [:pointer, :uint32], :void

    attach_function :_textinput_text,     :Gosu_TextInput_text,     [:pointer], :string
    attach_function :_textinput_set_text, :Gosu_TextInput_set_text, [:pointer, :string], :void

    @@text_inputs = {}

    def self.__from_pointer(pointer)
      @@text_inputs.dig(pointer.address)
    end

    def initialize
      @__text_input = _create_textinput
      @@text_inputs[@__text_input.address] = self
    end

    def __pointer
      @__text_input
    end

    def text
      _textinput_text(@__text_input)
    end

    def text=(string)
      _textinput_set_text(@__text_input, string)
    end

    def caret_pos
      _textinput_caret_pos(@__text_input)
    end

    def caret_pos=(int)
      _textinput_set_caret_pos(@__text_input, int)
    end

    def selection_start
      _textinput_selection_start(@__text_input)
    end

    def selection_start=(int)
      _textinput_set_selection_start(@__text_input, int)
    end

    def filter(text) # TODO: make #filter a callback
      text
    end

    def free_object
      _destroy_textinput(@__text_input)
      @@text_inputs[@__text_input.address] = nil
    end
  end
end