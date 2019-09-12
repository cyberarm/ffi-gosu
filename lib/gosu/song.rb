module Gosu
  class Song
    def self.current_song
    end

    def initialize(filename_or_pointer)
      if filename_or_pointer.is_a?(String)
        @__song = _create_song(filename_or_pointer)
      elsif filename_or_pointer.is_a?(FFI::Pointer)
        @__song = filename_or_pointer
      else
        pp filename_or_pointer
        raise ArgumentError
      end
    end

    def __pointer
      @__song
    end

    def play(looping = false)
    end

    def playing?
    end

    def pause
    end

    def paused?
    end

    def stop
    end

    def volume
    end

    def volume=(double)
      0
    end
  end

  def free_object
  end
end