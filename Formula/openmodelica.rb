class Openmodelica < Formula
  desc "OpenModelica is an open-source Modelica-based modeling and simulation environment intended for industrial and academic usage."
  homepage "https://openmodelica.org"
  url "https://github.com/OpenModelica/OpenModelica.git", :using => :git, :tag => "v1.14.2"
  version "1.14.2"
  head "https://github.com/OpenModelica/OpenModelica.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "cmake" => :build
  depends_on "gcc@9" => :build

  depends_on "boost"
  depends_on "hwloc"
  depends_on "lapack"
  depends_on "openblas" => "with-openmp"
  depends_on "brewsci/science/lp_solve" => "with-python"
  depends_on "hdf5"
  depends_on "expat"
  depends_on "gettext"
  depends_on "ncurses"
  depends_on "readline"
  depends_on "omniorb"
  depends_on "sundials"
  depends_on "yohey/legacy/qt@5.5"

  patch :DATA

  def install
    ENV.append "CXXFLAGS", "-stdlib=libc++"
    ENV.append "LDFLAGS",  "-stdlib=libc++"

    ENV["FC"] = "#{Formula["gcc@9"].opt_bin}/gfortran-9"

    args = %W[
      --prefix=#{prefix}
      --with-omniORB=#{Formula["omniorb"].opt_prefix}
      --with-omlibrary=all
    ]

    system "autoconf"
    system "./configure", *args

    system "make", "omc"
    system "make", "omplot"
    system "make", "omedit"
    system "make", "omnotebook"
    system "make", "omshell"
    # system "make", "omoptim" # fails
    system "make", "testsuite-depends"
    system "make", "omlibrary-all"
    system "make", "install"
  end

  test do
    assert_match "OMCompiler v#{version}", shell_output("#{prefix}/bin/omc --version 2>&1", 0)
  end
end

__END__
--- a/Makefile.in
+++ b/Makefile.in
@@ -99,7 +99,7 @@ bindir = @bindir@
 libdir = @libdir@
 includedir = @includedir@
 docdir = @docdir@
-INSTALL_APPDIR     = ${DESTDIR}/Applications/MacPorts/
+INSTALL_APPDIR     = ${DESTDIR}${prefix}/Applications/
 INSTALL_BINDIR     = ${DESTDIR}${bindir}
 INSTALL_LIBDIR     = ${DESTDIR}${libdir}
 INSTALL_INCLUDEDIR = ${DESTDIR}${includedir}
--- a/OMCompiler/configure.ac
+++ b/OMCompiler/configure.ac
@@ -278,7 +278,7 @@ else # Is Darwin
 
 AC_LANG_PUSH([C++])
 OLD_CXXFLAGS=$CXXFLAGS
-for flag in -stdlib=libstdc++; do
+for flag in -stdlib=libc++; do
   CXXFLAGS="$OLD_CXXFLAGS $flag"
   AC_TRY_LINK([], [return 0;], [LDFLAGS_LIBSTDCXX="$flag"],[CXXFLAGS="$OLD_CXXFLAGS"])
 done
--- a/OMPlot/qwt/Makefile.unix.in
+++ b/OMPlot/qwt/Makefile.unix.in
@@ -14,7 +14,7 @@ all: build
 
 Makefile: qwt.pro
 	@rm -f $@
-	$(QMAKE) QMAKE_CXX=@CXX@ QMAKE_CXXFLAGS="@CXXFLAGS@" QMAKE_LINK="@CXX@" qwt.pro
+	$(QMAKE) QMAKE_CXX=@CXX@ QMAKE_CXXFLAGS="@CXXFLAGS@" QMAKE_LINK="@CXX@" QMAKE_LFLAGS="@LDFLAGS@" qwt.pro
 clean:
 	test ! -f Makefile || $(MAKE) -f Makefile clean
 	rm -rf build lib Makefile
--- a/OMOptim/OMOptimBasis/Tools/LowTools.cpp
+++ b/OMOptim/OMOptimBasis/Tools/LowTools.cpp
@@ -465,7 +465,7 @@ int LowTools::round(double d)
 
 double LowTools::round(double d, int nbDecimals)
 {
-    return floor(d * std::pow(10,nbDecimals) + 0.5) / std::pow(10,nbDecimals);
+    return floor(d * std::pow(static_cast<double>(10),nbDecimals) + 0.5) / std::pow(static_cast<double>(10),nbDecimals);
 }
 
 double LowTools::roundToMultiple(double value, double multiple)
