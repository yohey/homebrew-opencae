class Acetk < Formula
  desc "Toolkit for working with ACE-formatted data files"
  homepage "https://github.com/njoy/ACEtk"
  head "https://github.com/njoy/ACEtk.git", :using => :git, :branch => "develop"

  keg_only ""

  depends_on "cmake" => :build
  depends_on "python@3.9"

  def install
    args = std_cmake_args
    args << "-DPYTHON_EXECUTABLE=#{Formula["python@3.9"].opt_bin}/python3"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "ACEtk.python"
      (lib/"python3.9/site-packages").install "ACEtk.cpython-39-darwin.so"
    end
  end

  # test do
  # end
end
