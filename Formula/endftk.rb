class Endftk < Formula
  desc "Toolkit for reading and interacting with ENDF-6 formatted files"
  homepage "https://github.com/njoy/ENDFtk"
  url "https://github.com/njoy/ENDFtk.git", :using => :git, :tag => "v0.3.0"
  version "0.3.0"
  revision 1
  head "https://github.com/njoy/ENDFtk.git"

  keg_only ""

  depends_on "cmake" => :build
  depends_on "python@3.9"

  def install
    args = std_cmake_args
    args << "-DPYTHON_EXECUTABLE=#{Formula["python@3.9"].opt_bin}/python3"

    patchFile = "#{File.dirname(__FILE__)}/../Patches/endftk-catch-adapter-fb84b82.patch"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "patch", "-p1", "-i", patchFile
      system "make", "-j#{ENV.make_jobs}", "install"
      system "make", "-j#{ENV.make_jobs}", "ENDFtk.python"
      (lib/"python3.9/site-packages").install "ENDFtk.cpython-39-darwin.so"
    end
  end

  # test do
  # end
end
