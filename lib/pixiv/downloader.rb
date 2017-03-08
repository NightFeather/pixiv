require 'pixiv/downloader/task'

module Pixiv
  class Downloader

    attr_reader :workdir, :suffix

    def initialize suffix = '.temp', workdir = Dir.pwd
      @workdir = workdir
      @suffix = suffix
    end

    def execute task
      unless task.is_a? Pixiv::Downloader::Task
        raise TypeError, "expect instance of `Pixiv::Downloader::Task`, get `#{task.class}`"
      end
      task.filelist.map do |file|
        _download file[:src], file[:dest], task.progress_callback, task.finish_callback
      end
    end

    def download artwork
      execute artwork.download_meta
    end

    def _download uri, path, progress_cb = nil, finish_cb = nil
      length = 0
      uri = URI(uri)

      path = File.join(workdir, path) unless path =~ /^\//

      unless File.exist? (File.dirname path)
        system 'mkdir', '-p', File.dirname(path)
      end

      Net::HTTP.start(uri.hostname, use_ssl: uri.scheme == 'https') do |http|
        File.open path + @suffix, "wb" do |f|
          http.get uri, referer: 'https://app-api.pixiv.net/' do |chunk|
            f << chunk
            length += chunk.length
            progress_cb.call path, length if progress_cb and progress_cb.respond_to? :call
          end
        end
      end

      File.rename(path + @suffix, path)
      finish_cb.call path, length if finish_cb and finish_cb.respond_to? :call
      return path
    end
  end
end
