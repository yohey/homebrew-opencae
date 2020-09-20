class OmlibExternalmedia < Formula
  desc "The ExternalMedia library provides a framework for interfacing external codes computing fluid properties to Modelica.Media-compatible component models."
  homepage "https://github.com/modelica-3rdparty/ExternalMedia"
  # url "https://github.com/modelica-3rdparty/ExternalMedia.git", :using => :git, :branch => "v.3.3.0-dev"
  # version "3.3.0-dev"
  head "https://github.com/slamer59/ExternalMedia.git"

  depends_on "cmake" => :build
  depends_on "coreutils" => :build

  depends_on "yohey/opencae/openmodelica"

  patch :DATA

  def install
    ENV.cxx11

    cd "Projects" do
      system "bash", "BuildLib-CMake.sh"
    end

    cd "Modelica/ExternalMedia 3.2.1/Resources/Library" do
      mv "Darwin", "darwin64"
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
@@ -19,12 +19,12 @@ NCPU=`nproc --all`
 CMAKE_SYSTEM_NAME='linux64'
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
@@ -39,13 +39,13 @@ if [ "$COOLP" == "1" ]; then
   if [ -d "$CP_SRC" ]; then
     pushd "$CP_SRC"
     git pull origin master
-    git checkout v6.1.0
+    git checkout v6.4.1
     git submodule init
     git submodule update
     # git submodule foreach git pull origin master
     popd 
   else
-    git clone -b v6.1.0 --single-branch --recursive https://github.com/CoolProp/CoolProp.git "$CP_SRC"
+    git clone -b v6.4.1 --single-branch --recursive https://github.com/CoolProp/CoolProp.git "$CP_SRC"
 #   git clone --recursive https://github.com/CoolProp/CoolProp.git "$CP_SRC"
   fi
 fi
--- a/Projects/CMakeLists.txt
+++ b/Projects/CMakeLists.txt
@@ -42,11 +42,13 @@ set  (INCLUDE_DIRS "")
 SET(COOLPROP_STATIC_LIBRARY OFF CACHE BOOL "Force the object library")
 SET(COOLPROP_SHARED_LIBRARY OFF CACHE BOOL "Force the object library")
 SET(COOLPROP_OBJECT_LIBRARY ON  CACHE BOOL "Force the object library")
+SET(CMAKE_MACOSX_RPATH      ON  CACHE BOOL "Force using relative path")
 ADD_SUBDIRECTORY ("${CMAKE_CURRENT_SOURCE_DIR}/../externals/CoolProp.git" "${CMAKE_CURRENT_BINARY_DIR}/CoolProp")
 list (APPEND INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/../externals/CoolProp.git")
 list (APPEND INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/../externals/CoolProp.git/include")
 list (APPEND INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/../externals/CoolProp.git/externals/msgpack-c/include")
 list (APPEND INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/../externals/CoolProp.git/externals/cppformat")
+list (APPEND INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/../externals/CoolProp.git/externals/fmtlib")
 
 ## We use CMake to handle the dependency since the primary VCS for 
 ## ExternalMedia still is SVN.
@@ -90,6 +92,7 @@ LIST (APPEND LIB_SOURCES $<TARGET_OBJECTS:CoolProp>)
 
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
--- a/Modelica/ExternalMedia 3.2.1/Media/BaseClasses/ExternalTwoPhaseMedium.mo	
+++ b/Modelica/ExternalMedia 3.2.1/Media/BaseClasses/ExternalTwoPhaseMedium.mo	
@@ -104,7 +104,7 @@ package ExternalTwoPhaseMedium "Generic external two phase medium package"
       "Specific entropy";
     SaturationProperties sat "saturation property record";
   equation
-    MM = externalFluidConstants.molarMass;
+    MM = fluidConstants.molarMass;
     R = Modelica.Constants.R/MM;
     if (onePhase or (basePropertiesInputChoice == InputChoice.pT)) then
       phaseInput = 1 "Force one-phase property computation";
