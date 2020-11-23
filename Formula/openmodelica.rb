class Openmodelica < Formula
  desc "OpenModelica is an open-source Modelica-based modeling and simulation environment intended for industrial and academic usage."
  homepage "https://openmodelica.org"
  url "https://github.com/OpenModelica/OpenModelica.git", :using => :git, :tag => "v1.16.1"
  version "1.16.1"
  head "https://github.com/OpenModelica/OpenModelica.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "cmake" => :build
  depends_on "gcc@9" => :build
  depends_on "svn" => :build
  depends_on "gnu-sed" => :build
  depends_on "pkg-config" => :build
  depends_on "xz" => :build

  depends_on "boost"
  depends_on "hwloc"
  depends_on "lapack"
  depends_on "openblas"
  depends_on "brewsci/science/lp_solve"
  depends_on "hdf5"
  depends_on "expat"
  depends_on "gettext"
  depends_on "ncurses"
  depends_on "readline"
  depends_on "sundials"
  depends_on "qt"
  depends_on "kde-mac/kde/qt-webkit"

  depends_on "omniorb" => :optional

  patch :DATA

  def install
    ENV.cxx11
    ENV["QMAKEPATH"] = "#{Formula["qt-webkit"].opt_prefix}"
    ENV["FC"] = "#{Formula["gcc@9"].opt_bin}/gfortran-9"

    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --with-lapack=-lopenblas
      --with-omlibrary=all
      --disable-modelica3d
    ]

    args << "--with-omniORB=#{Formula["omniorb"].opt_prefix}" if build.with? "omniorb"

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
@@ -110,7 +110,7 @@ bindir = @bindir@
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
--- a/OMOptim/OMOptimBasis/Tools/LowTools.cpp
+++ b/OMOptim/OMOptimBasis/Tools/LowTools.cpp
@@ -465,7 +465,7 @@ int LowTools::round(double d)
 
 double LowTools::round(double d, int nbDecimals)
 {
-    return floor(d * std::pow(10,nbDecimals) + 0.5) / std::pow(10,nbDecimals);
+    return floor(d * std::pow(static_cast<double>(10),nbDecimals) + 0.5) / std::pow(static_cast<double>(10),nbDecimals);
 }
 
 double LowTools::roundToMultiple(double value, double multiple)
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
--- a/OMPlot/qwt/src/qwt_null_paintdevice.h
+++ b/OMPlot/qwt/src/qwt_null_paintdevice.h
@@ -13,6 +13,7 @@
 #include "qwt_global.h"
 #include <qpaintdevice.h>
 #include <qpaintengine.h>
+#include <qpainterpath.h>
 
 /*!
   \brief A null paint device doing nothing
--- a/OMPlot/qwt/src/qwt_painter.h
+++ b/OMPlot/qwt/src/qwt_painter.h
@@ -17,6 +17,7 @@
 #include <qpen.h>
 #include <qline.h>
 #include <qpalette.h>
+#include <qpainterpath.h>
 
 class QPainter;
 class QBrush;
--- a/common/m4/qmake.m4
+++ b/common/m4/qmake.m4
@@ -42,6 +42,7 @@ if test -n "$QMAKE"; then
     echo 'cat $MAKEFILE | \
       sed "s/-arch@<:@\\@:>@* i386//g" | \
       sed "s/-arch@<:@\\@:>@* x86_64//g" | \
+      sed "s/-arch@<:@\\@:>@* \\$(arch)//g" | \
       sed "s/-arch//g" | \
       sed "s/-Xarch@<:@^ @:>@*//g" > $MAKEFILE.fixed && \
       mv $MAKEFILE.fixed $MAKEFILE' >> qmake.sh
