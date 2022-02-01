class OpenmodelicaAT118 < Formula
  desc "OpenModelica is an open-source Modelica-based modeling and simulation environment intended for industrial and academic usage."
  homepage "https://openmodelica.org"
  url "https://github.com/OpenModelica/OpenModelica.git", :using => :git, :tag => "v1.18.1"
  version "1.18.1"
  head "https://github.com/OpenModelica/OpenModelica.git"

  keg_only :versioned_formula

  depends_on "autoconf@2.69" => :build
  depends_on "automake" => :build
  depends_on "cmake" => :build
  depends_on "gcc" => :build
  depends_on "gnu-sed" => :build
  depends_on "libtool" => :build
  depends_on "openjdk" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "gettext"
  depends_on "hdf5"
  depends_on "hwloc"
  depends_on "lp_solve"
  depends_on "omniorb"
  depends_on "openblas"
  depends_on "readline"
  depends_on "sundials"
  depends_on "qt@5"
  depends_on "kde-mac/kde/qt-webkit"

  conflicts_with "open-scene-graph", because: "\"error: unknown type name 'GLDEBUGPROC'\""

  uses_from_macos "curl"
  uses_from_macos "expat"
  uses_from_macos "libffi", since: :catalina
  uses_from_macos "ncurses"

  patch :DATA

  def install
    ENV.cxx11
    ENV["QMAKEPATH"] = "#{Formula["qt-webkit"].opt_prefix}"
    ENV["FC"] = "#{Formula["gcc"].opt_bin}/gfortran"

    if MacOS.version >= :catalina
      ENV.append_to_cflags "-I#{MacOS.sdk_path_if_needed}/usr/include/ffi"
    else
      ENV.append_to_cflags "-I#{Formula["libffi"].opt_include}"
    end

    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-modelica3d
      --with-cppruntime
      --with-hwloc
      --with-lapack=-lopenblas
      --with-omlibrary=all
      --with-omniORB
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
--- a/OMEdit/OMEditLIB/MainWindow.cpp
+++ b/OMEdit/OMEditLIB/MainWindow.cpp
@@ -2717,8 +2717,8 @@ void MainWindow::runOMSensPlugin()
     pModelInterface->analyzeModel(pModelWidget->toOMSensData());
   } else {
     QMessageBox::information(this, QString("%1 - %2").arg(Helper::applicationName).arg(Helper::information), tr("Please open a model before starting the OMSens plugin."), Helper::ok);
-  }
 #endif
+  }
 }
 
 /*!
