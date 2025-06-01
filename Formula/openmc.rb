class Openmc < Formula
  desc "OpenMC Monte Carlo Code"
  homepage "https://openmc.org/"
  url "https://github.com/openmc-dev/openmc.git", :tag => "v0.15.2"
  version "v0.15.2"
  head "https://github.com/openmc-dev/openmc.git", :branch => "develop"

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "pkg-config" => :build

  depends_on "libomp"
  depends_on "libpng"
  depends_on "pugixml"
  depends_on "fmt"
  # depends_on "xtensor" # require <= 0.25.0
  depends_on "catch2"

  depends_on "open-mpi" => :optional
  depends_on "python3" => :optional

  if build.with? "open-mpi"
    depends_on "hdf5-mpi"
  else
    depends_on "hdf5"
  end

  def install
    args = std_cmake_args

    args << "-DOPENMC_USE_OPENMP=ON"

    args << "-DCMAKE_C_COMPILER=#{Formula["llvm"].opt_bin}/clang"
    args << "-DCMAKE_CXX_COMPILER=#{Formula["llvm"].opt_bin}/clang++"

    if build.with? "open-mpi"
      args << "-DOPENMC_USE_MPI=ON"
    end

    ENV["OpenMP_ROOT"] = "#{Formula["libomp"].opt_prefix}"

    system "cmake", "-S", ".", "-B", "Build", *args
    system "cmake", "--build", "Build", "-j#{ENV.make_jobs}"
    system "cmake", "--install", "Build"

    if build.with? "python3"
      python = Formula["python3"].opt_bin/"python3"
      system python, "-m", "pip", "install", ".", "--prefix=#{prefix}"
    end
  end

  test do
    system "cmake", "--build", "Build", "--target", "test"
  end
end
