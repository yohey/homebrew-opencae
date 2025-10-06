class Openmc < Formula
  desc "OpenMC Monte Carlo Code"
  homepage "https://openmc.org/"
  url "https://github.com/openmc-dev/openmc.git", :tag => "v0.15.2"
  version "v0.15.2"
  revision 1
  head "https://github.com/openmc-dev/openmc.git", :branch => "develop"

  depends_on "cmake" => :build
  depends_on "llvm@20" => :build
  depends_on "pkg-config" => :build

  depends_on "open-mpi"
  depends_on "hdf5-mpi"

  depends_on "eigen"
  depends_on "libomp"
  depends_on "libpng"
  depends_on "pugixml"
  depends_on "fmt"
  depends_on "catch2"
  depends_on "metis"

  depends_on "python@3.13"
  depends_on "python-setuptools"

  resource "moab" do
    url "https://bitbucket.org/fathomteam/moab.git", :tag => "5.5.1"
    patch :DATA
  end

  resource "dagmc" do
    url "https://github.com/svalinn/DAGMC.git", :tag => "v3.2.4"
  end

  def install
    resource("moab").stage do
      args = std_cmake_args(install_prefix: libexec/"moab")

      args << "-DENABLE_MPI=ON"
      args << "-DMPI_HOME=#{Formula["open-mpi"].opt_prefix}"
      args << "-DENABLE_HDF5=ON"
      args << "-DHDF5_ROOT=#{Formula["hdf5-mpi"].opt_prefix}"
      args << "-DENABLE_METIS=ON"
      args << "-DMETIS_ROOT=#{Formula["metis"].opt_prefix}"
      args << "-DBUILD_SHARED_LIBS=ON"
      args << "-DENABLE_PYMOAB=ON"

      system "cmake", "-S", ".", "-B", "Build", *args
      system "cmake", "--build", "Build", "-j#{ENV.make_jobs}"
      system "cmake", "--install", "Build"
    end

    resource("dagmc").stage do
      args = std_cmake_args(install_prefix: libexec/"dagmc")

      args << "-DCMAKE_C_COMPILER=#{Formula["llvm@20"].opt_bin}/clang"
      args << "-DCMAKE_CXX_COMPILER=#{Formula["llvm@20"].opt_bin}/clang++"
      args << "-DOpenMP_ROOT=#{Formula["libomp"].opt_prefix}"
      args << "-DOpenMP_CXX_FLAGS=-fopenmp=libomp -I#{Formula["libomp"].opt_include}"
      args << "-DMOAB_DIR=#{libexec}/moab"
      args << "-DBUILD_TALLY=ON"

      system "cmake", "-S", ".", "-B", "Build", *args
      system "cmake", "--build", "Build", "-j#{ENV.make_jobs}"
      system "cmake", "--install", "Build"
    end

    args = std_cmake_args

    args << "-DOPENMC_USE_OPENMP=ON"

    args << "-DCMAKE_C_COMPILER=#{Formula["llvm@20"].opt_bin}/clang"
    args << "-DCMAKE_CXX_COMPILER=#{Formula["llvm@20"].opt_bin}/clang++"
    args << "-DOPENMC_USE_MPI=ON"
    args << "-DOPENMC_USE_DAGMC=ON"
    args << "-DDAGMC_ROOT=#{libexec}/dagmc"
    args << "-DOpenMP_ROOT=#{Formula["libomp"].opt_prefix}"
    args << "-DHDF5_PREFER_PARALLEL=TRUE"

    system "cmake", "-S", ".", "-B", "Build", *args
    system "cmake", "--build", "Build", "-j#{ENV.make_jobs}"
    system "cmake", "--install", "Build"

    python = Formula["python@3.13"].opt_bin/"python3"
    system python, "-m", "pip", "install", ".", "--prefix=#{prefix}"
  end

  test do
    system "cmake", "--build", "Build", "--target", "test"
  end
end

__END__
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -164,8 +164,12 @@ set( HAVE_INTTYPES_H    ${MOAB_HAVE_INTTYPES_H} )
 set( HAVE_STDLIB_H    ${MOAB_HAVE_STDLIB_H} )
 check_include_file( memory.h     MOAB_HAVE_MEMORY_H )
 
-INCLUDE(TestBigEndian)
-TEST_BIG_ENDIAN(WORDS_BIGENDIAN)
+if (CMAKE_VERSION VERSION_LESS "3.20.0")
+  INCLUDE(TestBigEndian)
+  TEST_BIG_ENDIAN(WORDS_BIGENDIAN)
+else ()
+  set(WORDS_BIGENDIAN $<STREQUAL:${CMAKE_C_BYTE_ORDER},BIG_ENDIAN>)
+endif ()
 ################################################################################
 # Integer size Related Settings
 ################################################################################
