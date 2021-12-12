class Njoy2016 < Formula
  desc "Nuclear data processing with legacy NJOY"
  homepage "https://www.njoy21.io/NJOY2016"
  url "https://github.com/njoy/NJOY2016.git", :using => :git, :tag => "2016.65"
  version "2016.65"
  head "https://github.com/njoy/NJOY2016.git"

  keg_only ""

  depends_on "cmake" => :build
  depends_on "gcc@9" => :build

  def install
    args = std_cmake_args
    args << "-DCMAKE_Fortran_COMPILER=#{Formula["gcc@9"].opt_bin}/gfortran-9"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end
  end

  # test do
  # end
end
