module Gosu
  class Song
    extend FFI::Library
    ffi_lib Gosu::LIBRARY_PATH

    attach_function :_song_current_song, :Gosu_Song_current_song, [], :pointer

    attach_function :_create_song, :Gosu_Song_create, [:string], :pointer
    attach_function :_destroy_song, :Gosu_Song_destroy, [:pointer], :void

    attach_function :_song_play,    :Gosu_Song_play,    [:pointer, :bool], :void
    attach_function :_song_playing, :Gosu_Song_playing, [:pointer],        :bool
    attach_function :_song_pause,   :Gosu_Song_pause,   [:pointer],        :void
    attach_function :_song_paused,  :Gosu_Song_paused,  [:pointer],        :bool
    attach_function :_song_stop,    :Gosu_Song_stop,    [:pointer],        :void

    attach_function :_song_volume,     :Gosu_Song_volume,     [:pointer],          :double
    attach_function :_song_set_volume, :Gosu_Song_set_volume, [:pointer, :double], :void

    def self.current_song
      ptr = _song_current_song
      unless ptr.null?
        @@current_song
      else
        nil
      end
    end

    def initialize(filename)
      __song = _create_song(filename)
      @memory_pointer = FFI::AutoPointer.new(__song, Gosu::Song.method(:release))
    end

    def __pointer
      @memory_pointer
    end

    def play(looping = false)
      @@current_song = self
      _song_play(__pointer, looping)
    end

    def playing?
      _song_playing(__pointer)
    end

    def pause
      _song_pause(__pointer)
    end

    def paused?
      _song_paused(__pointer)
    end

    def stop
      _song_stop(__pointer)
    end

    def volume
      _song_volume(__pointer)
    end

    def volume=(double)
      _song_set_volume(__pointer, double.clamp(0.0, 1.0))
    end

    def self.release(pointer)
      _destroy_song(pointer)
    end
  end
end