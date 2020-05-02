module Gosu
  # Support for KbLeft instead of KB_LEFT and Gp3Button2 instead of GP_3_BUTTON_2.
  Gosu.constants.grep(/^KB_|MS_|GP_/).each do |new_name|
    old_name = case new_name
    when :KB_ISO then "KbISO"
    when :KB_NUMPAD_PLUS then "KbNumpadAdd"
    when :KB_NUMPAD_MINUS then "KbNumpadSubtract"
    when :KB_EQUALS then "KbEqual"
    when :KB_LEFT_BRACKET then "KbBracketLeft"
    when :KB_RIGHT_BRACKET then "KbBracketRight"
    else new_name.to_s.capitalize.gsub(/_(.)/) { $1.upcase }
    end
    Gosu.const_set old_name, Gosu.const_get(new_name)
  end

  class Window
    # Compat code taken from gosu/gosu

    %w(update draw needs_redraw? needs_cursor?
      lose_focus button_down button_up axis_motion gamepad_connected gamepad_disconnected drop close).each do |callback|
      define_method "protected_#{callback}" do |*args|
        begin
          # If there has been an exception, don't do anything as to not make matters worse.
          # Conveniently turn the return value into a boolean result (for needs_cursor? etc).
          defined?(@__exception) ? false : !!send(callback, *args)
        rescue Exception => e
          # Exit the message loop naturally, then re-throw during the next tick.
          @__exception = e
          close!
          false
        end
      end
    end

    %w(draw_line draw_triangle draw_quad draw_rect
      flush gl clip_to record
      transform translate rotate scale
      button_id_to_char char_to_button_id button_down?).each do |method|
      define_method method.to_sym do |*args, &block|
        Gosu.send method, *args, &block
      end
    end
  end
end
