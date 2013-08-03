require 'carrierwave/processing/mime_types'
require 'securerandom'

module CarrierWave::Storage
  class Memory < Abstract
    def initialize(*args)
      super
      @@store ||= {}
    end

    def store!(file)
      @@store[uploader.filename] = file.read
    end

    def retrieve!(identifier)
      CarrierWave::SanitizedFile.new(StringIO.new(@@store[identifier]))
    end
  end
end


CarrierWave.configure do |config|

  if Rails.env.test?
    config.enable_processing = false
  elsif !Rails.env.development?
    S3 = YAML.load_file(Rails.root.join("config/s3.yml"))[Rails.env]

    config.storage = :fog
    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => S3['access_key_id'],
      :aws_secret_access_key  => S3['secret_access_key'],
      :region                 => 'eu-west-1'
    }
    config.fog_directory  = S3['bucket']
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
  end
end


class CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  process :set_content_type
  process :optimize

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}".tap do |s|
      s.prepend "test_" if Rails.env.test?
    end
  end

  def filename
    return unless original_filename
    @random_filename ||= [model ? model_random_id : random_id,
                          file.extension].join('.')
  end

  def optimize
    manipulate! do |img|
      img.strip
      img.combine_options do |c|
        c.quality "80"
        c.depth "8"
        c.interlace "plane"
      end

      img
    end
  end

private
  def model_random_id
    var = :"@#{mounted_as}_random_id"
    model.instance_variable_get(var) || model.instance_variable_set(var, random_id)
  end

  def random_id
    SecureRandom.urlsafe_base64(32)
  end
end