class OmlibExternalmedia < Formula
  desc "The ExternalMedia library provides a framework for interfacing external codes computing fluid properties to Modelica.Media-compatible component models."
  homepage "https://github.com/modelica-3rdparty/ExternalMedia"
  url "https://github.com/modelica-3rdparty/ExternalMedia.git", :using => :git, :branch => "v.3.3.0-dev"
  version "3.3.0-dev"
  head "https://github.com/modelica-3rdparty/ExternalMedia.git"

  depends_on "cmake" => :build
  depends_on "coreutils" => :build

  depends_on "yohey/opencae/openmodelica"

  patch :DATA

  def install
    ENV.cxx11

    cd "Projects" do
      system "bash", "BuildLib-CMake.sh"
    end

    (lib/"omlibrary").mkpath
    (lib/"omlibrary").install Dir["Modelica/ExternalMedia 3.2.1"]
  end

  # test do
  # end
end

__END__
--- a/Projects/BuildLib-CMake.sh
+++ b/Projects/BuildLib-CMake.sh
@@ -18,16 +18,16 @@
 
 EXTERNALS="../externals"
 if [ ! -d "$EXTERNALS" ]; then mkdir -p "$EXTERNALS"; fi
-EXTERNALS=`readlink -f "$EXTERNALS"`
+EXTERNALS=`greadlink -f "$EXTERNALS"`
 CP_SRC="${EXTERNALS}/CoolProp.git"
 
 BUILD_DIR="build"
 if [ ! -d "$BUILD_DIR" ]; then mkdir -p "$BUILD_DIR"; fi
-BUILD_DIR=`readlink -f "$BUILD_DIR"`
+BUILD_DIR=`greadlink -f "$BUILD_DIR"`
 
 echo " "
 echo "********* Detecting supported property libraries ***********"
-FLUIDP=1
+FLUIDP=0
 COOLP=1
 echo "FluidProp support set to: $FLUIDP"
 echo  "CoolProp support set to: $COOLP"
@@ -39,12 +39,23 @@ if [ "$COOLP" == "1" ]; then
     pushd "$CP_SRC"
     git pull origin master
     git submodule init
-    git submodule update
+    # git submodule update
     # git submodule foreach git pull origin master
     popd 
   else
     git clone --recursive https://github.com/CoolProp/CoolProp.git "$CP_SRC"
   fi
+  pushd "$CP_SRC"
+  git checkout v5.1.2
+  rm -rf externals/ExcelAddinInstaller
+  rm -rf externals/fmtlib
+  rm -rf externals/pybind11
+  rm -rf externals/rapidjson
+  git submodule update $(find externals -type d -not -name 'Eigen' -mindepth 1 -maxdepth 1)
+  (cd externals/msgpack-c && git reset --hard)
+  (cd externals/Eigen && git checkout 3.2.9)
+  gsed -i '145s/UNIX/CMAKE_DL_LIBS/' CMakeLists.txt
+  popd
 fi
 
 pushd "$BUILD_DIR"
--- a/Projects/CMakeLists.txt
+++ b/Projects/CMakeLists.txt
@@ -42,6 +42,7 @@ set  (INCLUDE_DIRS "")
 SET(COOLPROP_STATIC_LIBRARY OFF CACHE BOOL "Force the object library")
 SET(COOLPROP_SHARED_LIBRARY OFF CACHE BOOL "Force the object library")
 SET(COOLPROP_OBJECT_LIBRARY ON  CACHE BOOL "Force the object library")
+SET(CMAKE_MACOSX_RPATH      ON  CACHE BOOL "Force using relative path")
 ADD_SUBDIRECTORY ("${CMAKE_CURRENT_SOURCE_DIR}/../externals/CoolProp.git" "${CMAKE_CURRENT_BINARY_DIR}/CoolProp")
 list (APPEND INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/../externals/CoolProp.git")
 list (APPEND INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/../externals/CoolProp.git/include")
@@ -90,6 +91,7 @@ LIST (APPEND LIB_SOURCES $<TARGET_OBJECTS:CoolProp>)
 
 add_library (${LIBRARY_NAME} STATIC ${LIB_SOURCES})
 set_property (TARGET ${LIBRARY_NAME} PROPERTY VERSION ${APP_VERSION})
+set_property (TARGET ${LIBRARY_NAME} APPEND_STRING PROPERTY COMPILE_FLAGS "-fPIC")
 add_dependencies (${LIBRARY_NAME} CoolProp)
 INSTALL(TARGETS "${LIBRARY_NAME}" DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/../Modelica/ExternalMedia ${APP_VERSION}/Resources/Library/${CMAKE_SYSTEM_NAME}" )
 INSTALL(FILES "${CMAKE_CURRENT_SOURCE_DIR}/Sources/${LIBRARY_HEADER}" DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/../Modelica/ExternalMedia ${APP_VERSION}/Resources/Include" )
--- a/Projects/Sources/include.h
+++ b/Projects/Sources/include.h
@@ -26,7 +26,7 @@
   compiler that is going to be used with the compiled library.
   \sa OPEN_MODELICA
 */
-#define DYMOLA 1
+#define DYMOLA 0
 
 //! Modelica compiler is OpenModelica
 /*!
@@ -34,7 +34,7 @@
   compiler that is going to be used with the compiled library.
   \sa DYMOLA
 */
-#define OPEN_MODELICA 0
+#define OPEN_MODELICA 1
 
 // Selection of used external fluid property computation packages.
 //! FluidProp solver
@@ -42,7 +42,7 @@
   Set this preprocessor variable to 1 to include the interface to the
   FluidProp solver developed and maintained by Francesco Casella.
 */
-#define FLUIDPROP 1
+#define FLUIDPROP 0
 
 // Selection of used external fluid property computation packages.
 //! CoolProp solver
