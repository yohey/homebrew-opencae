class Su2 < Formula
  desc "SU2: An Open-Source Suite for Multiphysics Simulation and Design"
  homepage "https://su2code.github.io"
  url "https://github.com/su2code/SU2/archive/v7.2.0.tar.gz"
  version "v7.2.0"
  sha256 "e929f25dcafc93684df2fe0827e456118d24b8b12b0fb74444bffa9b3d0baca8"
  head "https://github.com/su2code/SU2.git", :branch => "master"

  option "with-debug", "Enable debug build"

  depends_on "meson" => :build
  depends_on "ninja" => :build

  depends_on "pkg-config" => :build
  depends_on "re2c" => :build
  depends_on "swig" => :build

  depends_on "openblas" => :optional
  depends_on "open-mpi" => :optional
  depends_on "python" => :optional

  depends_on "mpi4py" if build.with?("python") && build.with?("open-mpi")

  def install
    args = std_meson_args

    args << "--buildtype=#{build.with?("debug") ? "debug" : "release"}"
    args << "-Denable-openblas=true" if build.with?("openblas")
    args << "-Denable-pywrapper=true" if build.with?("python")

    mkdir "build" do
      system "meson", *args, ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end

    share.install "config_template.cfg"
    share.install "TestCases"
  end

  test do
    system "SU2_CFD", "--help"
  end
end

__END__
