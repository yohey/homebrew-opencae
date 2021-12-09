class Njoy21 < Formula
  desc "NJOY for the 21st Century"
  homepage "https://www.njoy21.io/NJOY21"
  url "https://github.com/njoy/NJOY21.git", :using => :git, :tag => "v1.2.2"
  version "1.2.2"
  head "https://github.com/njoy/NJOY21.git"

  keg_only ""

  depends_on "cmake" => :build
  depends_on "gcc@9" => :build

  def install
    args = std_cmake_args
    args << "-DCMAKE_Fortran_COMPILER=#{Formula["gcc@9"].opt_bin}/gfortran-9"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  # test do
  # end
end
