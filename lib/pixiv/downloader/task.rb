module Pixiv
  class Downloader
    class Task
      attr_accessor :filelist
      attr_accessor :progress_callback, :finish_callback
      def initialize filelist
        @filelist = [filelist].flatten
      end
    end
  end
end

