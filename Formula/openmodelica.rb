class Openmodelica < Formula
  desc "OpenModelica is an open-source Modelica-based modeling and simulation environment intended for industrial and academic usage."
  homepage "https://openmodelica.org"
  url "https://github.com/OpenModelica/OpenModelica.git", :using => :git, :tag => "v1.16.5"
  version "1.16.5"
  head "https://github.com/OpenModelica/OpenModelica.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "cmake" => :build
  depends_on "gcc@9" => :build
  depends_on "openjdk" => :build
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
  depends_on "qt@5"
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
--- a/OMEdit/OMEditLIB/Editors/BaseEditor.cpp
+++ b/OMEdit/OMEditLIB/Editors/BaseEditor.cpp
@@ -998,7 +998,7 @@ void PlainTextEdit::lineNumberAreaPaintEvent(QPaintEvent *event)
          * So I use QStyle::PE_IndicatorArrowDown and QStyle::PE_IndicatorArrowRight
          * Perhaps this is fixed in newer Qt versions. We will see when we use Qt 5 for MAC.
          */
-#ifndef Q_OS_MAC
+#ifndef Q_OS_DARWIN
         if (expanded) {
           styleOptionViewItem.state |= QStyle::State_Open;
         }
--- a/OMEdit/OMEditLIB/MainWindow.cpp
+++ b/OMEdit/OMEditLIB/MainWindow.cpp
@@ -2694,17 +2694,19 @@ void MainWindow::runOMSensPlugin()
     // load OMSens plugin
 #ifdef Q_OS_WIN
     QPluginLoader loader(QString("%1/lib/omc/omsensplugin.dll").arg(Helper::OpenModelicaHome));
-#elif defined(Q_OS_MAC)
+#elif defined(Q_OS_DARWIN)
     MessagesWidget::instance()->addGUIMessage(MessageItem(MessageItem::Modelica, tr("OMSens is not supported on MacOS"), Helper::scriptingKind, Helper::errorLevel));
     return;
 #else
     QPluginLoader loader(QString("%1/lib/%2/omc/libomsensplugin.so").arg(Helper::OpenModelicaHome, HOST_SHORT));
 #endif
+#ifndef Q_OS_DARWIN
     mpOMSensPlugin = loader.instance();
     if (!mpOMSensPlugin) {
       MessagesWidget::instance()->addGUIMessage(MessageItem(MessageItem::Modelica, tr("Failed to load OMSens plugin. %1").arg(loader.errorString()), Helper::scriptingKind, Helper::errorLevel));
       return;
     }
+#endif
   }
   // if OMSens plugin is already loaded.
   InformationInterface *pInformationInterface = qobject_cast<InformationInterface*>(mpOMSensPlugin);
@@ -3948,7 +3950,7 @@ void MainWindow::createMenus()
   pOMSimulatorMenu->addAction(mpAddSubModelAction);
   // add OMSimulator menu to menu bar
   menuBar()->addAction(pOMSimulatorMenu->menuAction());
-#ifndef Q_OS_MAC
+#ifndef Q_OS_DARWIN
   // Sensitivity Optimization menu
   QMenu *pSensitivityOptimizationMenu = new QMenu(menuBar());
   pSensitivityOptimizationMenu->setTitle(tr("Sensitivity Optimization"));
--- a/OMEdit/OMEditLIB/Modeling/MessagesWidget.cpp
+++ b/OMEdit/OMEditLIB/Modeling/MessagesWidget.cpp
@@ -417,7 +417,7 @@ MessagesWidget::MessagesWidget(QWidget *pParent)
   mSuppressMessagesList.clear();
 #ifdef Q_OS_WIN
   // nothing
-#elif defined(Q_OS_MAC)
+#elif defined(Q_OS_DARWIN)
   mSuppressMessagesList << "modalSession has been exited prematurely*"; /* This warning is fixed in latest Qt versions but out OSX build still uses old Qt. */
 #else
   mSuppressMessagesList << "libpng warning*" /* libpng warning comes from QWebView default images. */
--- a/OMEdit/OMEditLIB/Modeling/ModelWidgetContainer.cpp
+++ b/OMEdit/OMEditLIB/Modeling/ModelWidgetContainer.cpp
@@ -3939,7 +3939,7 @@ WelcomePageWidget::WelcomePageWidget(QWidget *pParent)
   // top frame heading
   mpHeadingLabel = Utilities::getHeadingLabel(QString(Helper::applicationName).append(" - ").append(Helper::applicationIntroText));
   mpHeadingLabel->setStyleSheet("background-color : transparent; color : white;");
-#ifndef Q_OS_MAC
+#ifndef Q_OS_DARWIN
   mpHeadingLabel->setGraphicsEffect(new QGraphicsDropShadowEffect);
 #endif
   mpHeadingLabel->setElideMode(Qt::ElideMiddle);
@@ -7781,7 +7781,7 @@ bool ModelWidgetContainer::eventFilter(QObject *object, QEvent *event)
     if (subWindowList(QMdiArea::ActivationHistoryOrder).size() > 0) {
       QKeyEvent *keyEvent = static_cast<QKeyEvent*>(event);
       // Ingore key events without a Ctrl modifier (except for press/release on the modifier itself).
-#ifdef Q_OS_MAC
+#ifdef Q_OS_DARWIN
       if (!(keyEvent->modifiers() & Qt::AltModifier) && keyEvent->key() != Qt::Key_Alt) {
 #else
       if (!(keyEvent->modifiers() & Qt::ControlModifier) && keyEvent->key() != Qt::Key_Control) {
@@ -7792,7 +7792,7 @@ bool ModelWidgetContainer::eventFilter(QObject *object, QEvent *event)
       const bool keyPress = (event->type() == QEvent::KeyPress) ? true : false;
       ModelWidget *pCurrentModelWidget = getCurrentModelWidget();
       switch (keyEvent->key()) {
-#ifdef Q_OS_MAC
+#ifdef Q_OS_DARWIN
         case Qt::Key_Alt:
 #else
         case Qt::Key_Control:
--- a/OMEdit/OMEditLIB/Options/OptionsDialog.cpp
+++ b/OMEdit/OMEditLIB/Options/OptionsDialog.cpp
@@ -1876,7 +1876,7 @@ GeneralSettingsPage::GeneralSettingsPage(OptionsDialog *pOptionsDialog)
   mpTerminalCommandTextBox = new QLineEdit;
 #ifdef Q_OS_WIN32
   mpTerminalCommandTextBox->setText("cmd.exe");
-#elif defined(Q_OS_MAC)
+#elif defined(Q_OS_DARWIN)
   mpTerminalCommandTextBox->setText("");
 #else
   mpTerminalCommandTextBox->setText("");
--- a/OMEdit/OMEditLIB/Util/Helper.cpp
+++ b/OMEdit/OMEditLIB/Util/Helper.cpp
@@ -98,7 +98,7 @@ QString Helper::utf8 = "UTF-8";
 const char * const Helper::fmuPlatformNamePropertyId = "fmu-platform-name";
 QFontInfo Helper::systemFontInfo = QFontInfo(QFont());
 QFontInfo Helper::monospacedFontInfo = QFontInfo(QFont());
-#ifdef Q_OS_MAC
+#ifdef Q_OS_DARWIN
 QString Helper::toolsOptionsPath = "OMEdit->Preferences";
 #else
 QString Helper::toolsOptionsPath = "Tools->Options";
--- a/OMNotebook/OMNotebook/OMNotebookGUI/qtapp.cpp
+++ b/OMNotebook/OMNotebook/OMNotebookGUI/qtapp.cpp
@@ -53,7 +53,7 @@
 #include "application.h"
 #include "cellapplication.h"
 
-#ifdef Q_OS_MAC
+#ifdef Q_OS_DARWIN
 //need to increase stack size on OSX
 #include <sys/resource.h>
 #include <sys/types.h>
@@ -74,7 +74,7 @@ using namespace IAEX;
 int main(int argc, char *argv[])
 {
 
-#ifdef Q_OS_MAC
+#ifdef Q_OS_DARWIN
   //need to increase stack size on OSX
   rlimit limits;
   getrlimit(RLIMIT_STACK, &limits);
--- a/OMOptim/OMOptim/Core/Util/Helper.cpp
+++ b/OMOptim/OMOptim/Core/Util/Helper.cpp
@@ -88,7 +88,7 @@ QString Helper::textOutput = "Text";
 QString Helper::utf8 = "UTF-8";
 QFontInfo Helper::systemFontInfo = QFontInfo(QFont());
 QFontInfo Helper::monospacedFontInfo = QFontInfo(QFont());
-#ifdef Q_OS_MAC
+#ifdef Q_OS_DARWIN
 QString Helper::toolsOptionsPath = "OMEdit->Preferences";
 #else
 QString Helper::toolsOptionsPath = "Tools->Options";
--- a/OMPlot/qwt/src/qwt_system_clock.cpp
+++ b/OMPlot/qwt/src/qwt_system_clock.cpp
@@ -63,7 +63,7 @@ double QwtSystemClock::elapsed() const
 #include <unistd.h>
 #endif
 
-#if defined(Q_OS_MAC)
+#if defined(Q_OS_DARWIN)
 #include <stdint.h>
 #include <mach/mach_time.h>
 #define QWT_HIGH_RESOLUTION_CLOCK
@@ -92,7 +92,7 @@ public:
 
 private:
 
-#if defined(Q_OS_MAC)
+#if defined(Q_OS_DARWIN)
     static double msecsTo( uint64_t, uint64_t );
 
     uint64_t d_timeStamp;
@@ -113,7 +113,7 @@ private:
 #endif
 };
 
-#if defined(Q_OS_MAC)
+#if defined(Q_OS_DARWIN)
 QwtHighResolutionClock::QwtHighResolutionClock():
     d_timeStamp( 0 )
 {
--- a/OMSens_Qt/OMSensDialog.cpp
+++ b/OMSens_Qt/OMSensDialog.cpp
@@ -34,7 +34,7 @@ QString osName()
   return QLatin1String("blackberry");
 #elif defined(Q_OS_IOS)
   return QLatin1String("ios");
-#elif defined(Q_OS_MACOS)
+#elif defined(Q_OS_DARWINOS)
   return QLatin1String("macos");
 #elif defined(Q_OS_TVOS)
   return QLatin1String("tvos");
