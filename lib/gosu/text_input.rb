module Gosu
  class TextInput
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    callback :_callback_filter, [:string], :string

    attach_function :_create_textinput,   :Gosu_TextInput_create,   [],         :pointer
    attach_function :_destroy_textinput,  :Gosu_TextInput_destroy,  [:pointer], :void

    attach_function :_textinput_caret_pos,            :Gosu_TextInput_caret_pos,           [:pointer],          :uint32
    attach_function :_textinput_set_caret_pos,        :Gosu_TextInput_set_caret_pos,       [:pointer, :uint32], :void
    attach_function :_textinput_selection_start,      :Gosu_TextInput_selection_start,     [:pointer],          :uint32
    attach_function :_textinput_set_selection_start,  :Gosu_TextInput_set_selection_start, [:pointer, :uint32], :void

    attach_function :_textinput_text,       :Gosu_TextInput_text,       [:pointer], :string
    attach_function :_textinput_set_text,   :Gosu_TextInput_set_text,   [:pointer, :string], :void
    attach_function :_textinput_set_filter, :Gosu_TextInput_set_filter, [:pointer, :_callback_filter], :void

    attach_function :_textinput_delete_backward, :Gosu_TextInput_delete_backward, [:pointer], :void
    attach_function :_textinput_delete_forward,  :Gosu_TextInput_delete_forward,  [:pointer], :void

    @@text_inputs = {}

    def self.__from_pointer(pointer)
      @@text_inputs.dig(pointer.address)
    end

    def initialize
      @__text_input = _create_textinput
      @@text_inputs[@__text_input.address] = self

      @__filter_proc = proc { |text| filter(text) }
      _textinput_set_filter(@__text_input, @__filter_proc)
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

    def filter(text)
      return text
    end

    def delete_backward
      _textinput_delete_backward(@__text_input)
    end

    def delete_forward
      _textinput_delete_forward(@__text_input)
    end

    def free_object
      _destroy_textinput(@__text_input)
      @@text_inputs[@__text_input.address] = nil
    end
  end
end