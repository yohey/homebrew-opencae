class Freecad < Formula
  desc "Parametric 3D modeler"
  homepage "http://www.freecadweb.org"
  url "https://github.com/FreeCAD/FreeCAD/archive/0.19_pre.tar.gz"
  # url "https://github.com/FreeCAD/FreeCAD.git", :using => :git, :branch => "0.19_pre"
  version "0.19_pre"
  sha256 "b16c17e83496ec34cd29ed208f4d6049984879ef953574dc3729a4be06e35b32"
  head "https://github.com/FreeCAD/FreeCAD.git", :branch => "master"

  # Debugging Support
  option "with-debug", "Enable debug build"

  # Option to build with legacy qt4
  option "with-qt4"

  # Optionally install packaging dependencies
  option "with-packaging-utils"

  # Build dependencies
  depends_on "cmake"   => :build
  depends_on "ccache"  => :build

  # Required dependencies
  depends_on :macos => :mavericks
  depends_on "freetype"
  depends_on "python@3.8"
  depends_on "boost-python3"
  depends_on "xerces-c"
  if build.with?("qt4")
    depends_on "cartr/qt4/qt@4"
    depends_on "cartr/qt4/pyside-tools@1.2"
  else
    depends_on "yohey/legacy/qt_5.11"
    depends_on "yohey/legacy/qtwebkit"
    depends_on "yohey/legacy/pyside2-tools"
    depends_on "webp"
  end
  depends_on "yohey/opencae/opencascade@7.3"
  depends_on "orocos-kdl"
  depends_on "yohey/legacy/matplotlib@2.1"
  depends_on "yohey/opencae/med-file"
  depends_on "vtk"
  depends_on "yohey/opencae/nglib@5.3"
  depends_on "FreeCAD/freecad/coin"
  depends_on "yohey/opencae/pivy@0.6"
  depends_on "swig@3" => :build

  if build.with?("packaging-utils")
    depends_on "node"
    depends_on "jq"
  end

  patch :DATA

  def install
    if build.with?("packaging-utils")
      system "node", "install", "-g", "app_dmg"
    end

    # Set up needed cmake args
    args = std_cmake_args
    if build.without?("qt4")
      args << "-DBUILD_QT5=ON"
      args << '-DCMAKE_PREFIX_PATH="' + Formula["qt_5.11"].opt_prefix + "/lib/cmake;" + Formula["yohey/legacy/qtwebkit"].opt_prefix + '/lib/cmake"'
    end
    args << "-DBUILD_FEM_NETGEN:BOOL=ON"
    args << "-DFREECAD_USE_EXTERNAL_KDL=ON"
    args << "-DCMAKE_BUILD_TYPE=#{build.with?("debug") ? "Debug" : "Release"}"
    args << "-DFREECAD_CREATE_MAC_APP=ON"

    python = Formula["python@3.8"]
    pyhome = `#{python.opt_bin}/python3-config --prefix`.chomp
    pyver = Language::Python.major_minor_version "#{pyhome}/bin/python3"

    args << "-DPYTHON_EXECUTABLE=#{pyhome}/bin/python#{pyver}"
    args << "-DPYTHON_LIBRARY=#{pyhome}/lib/libpython#{pyver}.dylib"
    args << "-DPYTHON_INCLUDE_DIR=#{pyhome}/include/python#{pyver}"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  def caveats; <<~EOS
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH
    EOS
  end
end

__END__
diff --git a/src/MacAppBundle/CMakeLists.txt b/src/MacAppBundle/CMakeLists.txt
index 91a56866a..b6c25ce55 100644
--- a/src/MacAppBundle/CMakeLists.txt
+++ b/src/MacAppBundle/CMakeLists.txt
@@ -31,6 +31,7 @@ if(HOMEBREW_PREFIX)
     foreach(PTH_FILE ${HOMEBREW_PTH_FILES})
         file(READ ${PTH_FILE} ADDITIONAL_DIR)
 
+        if(EXISTS "${ADDITIONAL_DIR}")
	string(STRIP "${ADDITIONAL_DIR}" ADDITIONAL_DIR)
         string(REGEX REPLACE "^${HOMEBREW_PREFIX}/Cellar/([A-Za-z0-9_]+).*$" "\\1" LIB_NAME ${ADDITIONAL_DIR})
         string(REGEX REPLACE ".*libexec(.*)/site-packages" "libexec/${LIB_NAME}\\1" NEW_SITE_DIR ${ADDITIONAL_DIR})
@@ -45,6 +46,9 @@ if(HOMEBREW_PREFIX)
		 \"../../../${NEW_SITE_DIR}/site-packages\"
             )"
         )
+        else()
+          message("Warning: The file \"${PTH_FILE}\" contains wrong path.")
+        endif()
     endforeach(PTH_FILE)
 endif()
 
