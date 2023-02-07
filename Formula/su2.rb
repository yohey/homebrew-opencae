class Su2 < Formula
  desc "SU2: An Open-Source Suite for Multiphysics Simulation and Design"
  homepage "https://su2code.github.io"
  url "https://github.com/su2code/SU2.git", :tag => "v7.5.1"
  version "v7.5.1"
  head "https://github.com/su2code/SU2.git", :branch => "master"

  option "with-debug", "Enable debug build"

  depends_on "pkg-config" => :build
  depends_on "re2c" => :build
  depends_on "swig" => :build

  depends_on "openblas" => :optional
  depends_on "open-mpi" => :optional

  option "with-python", "Build with python support"
  depends_on "python@3.11" if build.with? "python"

  depends_on "mpi4py" if (build.with? "python") && (build.with? "open-mpi")

  def install
    args = std_meson_args

    args << "--buildtype=#{build.with?("debug") ? "debug" : "release"}"
    args << "-Denable-openblas=true" if build.with?("openblas")
    args << "-Denable-pywrapper=true" if build.with?("python")

    system "python3", "meson.py", *args, "_build"
    system "./ninja", "-C", "_build", "-v"
    system "./ninja", "-C", "_build", "-v", "install"

    share.install "config_template.cfg"
    share.install "TestCases"
  end

  test do
    system "SU2_CFD", "--help"
  end
end
