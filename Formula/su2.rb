class Su2 < Formula
  desc "SU2: An Open-Source Suite for Multiphysics Simulation and Design"
  homepage "https://su2code.github.io"
  url "https://github.com/su2code/SU2/archive/v7.0.7.tar.gz"
  version "v7.0.7"
  sha256 "123c42f097c583a3d7b53123d79bf470f67a6481851fddb010ff590837da61d4"
  head "https://github.com/su2code/SU2.git", :branch => "master"

  option "with-debug", "Enable debug build"

  depends_on "meson" => :build
  depends_on "ninja" => :build

  depends_on "pkg-config" => :build
  depends_on "re2c" => :build
  depends_on "swig" => :build

  depends_on "openblas" => :optional
  depends_on "open-mpi" => :optional
  depends_on "python@3.8" => :optional

  depends_on "mpi4py" if build.with?("python@3.8") && build.with?("open-mpi")

  patch :DATA

  def install
    args = std_meson_args

    args << "--buildtype=#{build.with?("debug") ? "debug" : "release"}"
    args << "-Denable-openblas=true" if build.with?("openblas")
    args << "-Denable-pywrapper=true" if build.with?("python@3.8")

    mkdir "build" do
      system "meson", *args, ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    system "SU2_CFD", "--help"
  end
end

__END__
diff --git a/Common/src/geometry/CPhysicalGeometry.cpp b/Common/src/geometry/CPhysicalGeometry.cpp
index eeeca24e67..1fd346b2aa 100644
--- a/Common/src/geometry/CPhysicalGeometry.cpp
+++ b/Common/src/geometry/CPhysicalGeometry.cpp
@@ -5929,6 +5929,7 @@ void CPhysicalGeometry::SetTurboVertex(CConfig *config, unsigned short val_iZone
     /*--- to be set for all the processor to initialize an appropriate number of frequency for the NR BC ---*/
     if(nVert > nVertMax){
       SetnVertexSpanMax(marker_flag,nVert);
+      nVertMax = nVert;
     }
     /*--- for all the processor should be known the amount of total turbovertex per span  ---*/
     nTotVertex_gb[iSpan]= (int)nVert;
