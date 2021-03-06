# encoding: utf-8
class SirTrevorImageUploader < CarrierWave::Uploader::Base

  def store_dir
    "uploads/editor".tap do |s|
      s.prepend "test_" if Rails.env.test?
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    "/assets/" + [version_name, "default.gif"].compact.join('_')
  end

  version :large do
    process resize_to_limit: [1280, nil]
  end

  version :medium do
    process resize_to_limit: [640, nil]
  end

  version :small do
    process resize_to_limit: [320, nil]
  end

  version :tiny do
    process resize_to_limit: [220, nil]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def as_json(options = nil)
    {
      file: super["uploader"]
    }
  end
end