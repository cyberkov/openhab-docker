# spec/image_spec.rb

describe "Image" do
  before(:all) do
    @image = Docker::Image.create('fromImage' => ENV['IMAGE'])
  end

  it "should exist" do
    expect(@image).not_to be_nil
  end

  describe "networking" do
    #EXPOSE 8080 8443 5555
    it "should expose the default ports" do
      expect(@image.json["Config"]["ExposedPorts"].has_key?("8080/tcp")).to be_truthy
      expect(@image.json["Config"]["ExposedPorts"].has_key?("8443/tcp")).to be_truthy
      expect(@image.json["Config"]["ExposedPorts"].has_key?("5555/tcp")).to be_truthy
    end
  end
end
