class OmlibExternalmedia < Formula
  desc "The ExternalMedia library provides a framework for interfacing external codes computing fluid properties to Modelica.Media-compatible component models."
  homepage "https://github.com/modelica-3rdparty/ExternalMedia"
  url "https://github.com/modelica-3rdparty/ExternalMedia.git", :using => :git, :tag => "v3.3.0"
  version "3.3.0"
  head "https://github.com/modelica-3rdparty/ExternalMedia.git"

  depends_on "cmake" => :build

  depends_on "openmodelica"

  patch :DATA

  def install
    ENV.cxx11
    args = std_cmake_args

    mkdir "Build" do
      system "cmake", *args, "../Projects"
      system "cmake", *args, "../Projects"
      system "cmake", "--build", ".", "--config", "Release", "--target", "install"
    end

    cd "Modelica/ExternalMedia 3.3.0/Resources/Library" do
      mv "linux64", "darwin64"
      system "ln", "-s", "clang130/libExternalMediaLib.dylib", "darwin64/"
    end

    (lib/"omlibrary").mkpath
    (lib/"omlibrary").install Dir["Modelica/ExternalMedia 3.3.0"]
  end

  # test do
  # end
end

__END__
--- a/Projects/CMakeLists.txt
+++ b/Projects/CMakeLists.txt
@@ -61,14 +61,15 @@ if(COOLPROP)
     #file(ARCHIVE_EXTRACT INPUT ${CMAKE_BINARY_DIR}/coolprop.zip)
     #execute_process(COMMAND unzip ${CMAKE_BINARY_DIR}/coolprop.zip -d "${CMAKE_BINARY_DIR}/coolprop-tmp")
     #execute_process(COMMAND sed -i '421s;^;\#;' "${CMAKE_BINARY_DIR}/coolprop-tmp/CoolProp.sources/CMakeLists.txt")
+    execute_process(COMMAND sed -i ".bak" "s/-stdlib=libstdc++ -mmacosx-version-min=10.6/-stdlib=libc++ -mmacosx-version-min=10.9/g" "${CMAKE_BINARY_DIR}/coolprop-tmp/CoolProp.sources/CMakeLists.txt")
     file(RENAME "${CMAKE_BINARY_DIR}/coolprop-tmp/CoolProp.sources" "${CMAKE_CURRENT_SOURCE_DIR}/../externals/CoolProp.git")
     file(REMOVE_RECURSE "${CMAKE_BINARY_DIR}/coolprop-tmp")
     file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/CoolProp")
   endif()
   # Configure CMake switches for CoolProp
   SET(COOLPROP_STATIC_LIBRARY OFF CACHE BOOL "Force the object library")
-  SET(COOLPROP_SHARED_LIBRARY OFF CACHE BOOL "Force the object library")
-  SET(COOLPROP_OBJECT_LIBRARY ON  CACHE BOOL "Force the object library")
+  SET(COOLPROP_SHARED_LIBRARY ON  CACHE BOOL "Force the object library")
+  SET(COOLPROP_OBJECT_LIBRARY OFF CACHE BOOL "Force the object library")
   # Force bitness for MinGW
   if(MINGW)
     if(CMAKE_SIZEOF_VOID_P MATCHES "8")
@@ -140,11 +141,11 @@ else()
 endif()
 
 # Add the target for ExternalMedia
-add_library(${LIBRARY_NAME} STATIC ${LIB_SOURCES})
+add_library(${LIBRARY_NAME} SHARED ${LIB_SOURCES})
 set_property(TARGET ${LIBRARY_NAME} PROPERTY VERSION ${APP_VERSION})
 target_compile_definitions(${LIBRARY_NAME} PRIVATE EXTERNALMEDIA_FLUIDPROP=$<IF:$<BOOL:${FLUIDPROP}>,1,0>)
 target_compile_definitions(${LIBRARY_NAME} PRIVATE EXTERNALMEDIA_COOLPROP=$<IF:$<BOOL:${COOLPROP}>,1,0>)
-target_compile_definitions(${LIBRARY_NAME} PRIVATE EXTERNALMEDIA_MODELICA_ERRORS=1) # Use 0 for a shared library and 1 for a static library
+target_compile_definitions(${LIBRARY_NAME} PRIVATE EXTERNALMEDIA_MODELICA_ERRORS=0) # Use 0 for a shared library and 1 for a static library
 #target_compile_definitions(${LIBRARY_NAME} PRIVATE EXTERNALMEDIA_LIBRARY_EXPORTS) # Use this for a shared library
 if(COOLPROP)
 add_dependencies(${LIBRARY_NAME} CoolProp)
