class OmlibExternalmedia < Formula
  desc "The ExternalMedia library provides a framework for interfacing external codes computing fluid properties to Modelica.Media-compatible component models."
  homepage "https://github.com/modelica-3rdparty/ExternalMedia"
  url "https://github.com/modelica-3rdparty/ExternalMedia.git", :using => :git, :tag => "v4.1.1"
  version "4.1.1"
  revision 1
  head "https://github.com/modelica-3rdparty/ExternalMedia.git"

  depends_on "cmake" => :build

  depends_on "yohey/opencae/openmodelica@1.25"

  def install
    args = std_cmake_args + %w[
      -DCMAKE_C_COMPILER=/usr/bin/clang
      -DCMAKE_CXX_COMPILER=/usr/bin/clang++
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    ]

    # The current version of ExternalMedia requires you to run the configure step twice.
    system "cmake", "-B", "build_cmake", "-S", "./Projects", *args
    system "cmake", "-B", "build_cmake", "-S", "./Projects", *args

    system "cmake", "--build", "build_cmake", "--config", "Release"
    system "cmake", "--build", "build_cmake", "--config", "Release", "--target", "install"

    system "mv", "Modelica/ExternalMedia", "Modelica/ExternalMedia #{version}"

    (lib/"omlibrary").mkpath
    (lib/"omlibrary").install Dir["Modelica/ExternalMedia #{version}"]

    if Hardware::CPU.arm?
      ln_s "aarch64-darwin", lib/"omlibrary/ExternalMedia #{version}/Resources/Library/arm64-darwin"
      ln_s "aarch64-darwin", lib/"omlibrary/ExternalMedia #{version}/Resources/Library/darwin64"
    end
  end

  # test do
  # end
end
