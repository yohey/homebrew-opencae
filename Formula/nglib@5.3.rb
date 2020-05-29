class NglibAT53 < Formula
  desc "C++ Library of NETGEN's tetrahedral mesh generator"
  homepage "https://sourceforge.net/projects/netgen-mesher/"
  url "https://downloads.sourceforge.net/project/netgen-mesher/netgen-mesher/5.3/netgen-5.3.1.tar.gz"
  sha256 "cb97f79d8f4d55c00506ab334867285cde10873c8a8dc783522b47d2bc128bf9"
  revision 1


  depends_on "yohey/opencae/opencascade@7.3" => :recommended

  # Patch two main issues:
  #   Makefile - remove TCL scripts that aren't reuquired without NETGEN.
  #   Partition_Loop2d.cxx - Fix PI that was used rather than M_PI
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/20850ac/nglib/define-PI-and-avoid-tcl-install.diff"
    sha256 "1f97e60328f6ab59e41d0fa096acbe07efd4c0a600d8965cc7dc5706aec25da4"
  end

  # OpenCascase 7.x compatibility patches
  if build.with? "opencascade@7.3"
    patch do
      url "https://github.com/FreeCAD/homebrew-freecad/releases/download/0/occt7.x-compatibility-patches.diff"
      sha256 "18e0491444610dc3a04db105984993e9035cc82d77ab12a93c2ca99a9b8bed33"
    end
  end

  def install
    ENV.cxx11 if build.with? "opencascade@7.3"

    cad_kernel = Formula["opencascade@7.3"]

    # Set OCC search path to Homebrew prefix
    inreplace "configure" do |s|
      s.gsub!(%r{(OCCFLAGS="-DOCCGEOMETRY -I\$occdir/inc )(.*$)}, "\\1-I#{cad_kernel.opt_include}/#{cad_kernel.to_s.sub(/@.*$/, "")}\"")
      s.gsub!(/(^.*OCCLIBS="-L.*)( -lFWOSPlugin")/, "\\1\"") if build.with? "opencascade@7.3"
      s.gsub!(%r{(OCCLIBS="-L\$occdir/lib)(.*$)}, "\\1\"") if OS.mac?
    end

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-gui
      --enable-nglib
    ]

    if build.with? "opencascade@7.3"
      args << "--enable-occ"
      args << "--with-occ=#{cad_kernel.opt_prefix}"
    end

    system "./configure", *args

    system "make", "install"

    # The nglib installer doesn't include some important headers by default.
    # This follows a pattern used on other platforms to make a set of sub
    # directories within include/ to contain these headers.
    subdirs = ["csg", "general", "geom2d", "gprim", "include", "interface",
               "linalg", "meshing", "occ", "stlgeom", "visualization"]
    subdirs.each do |subdir|
      (include/"netgen"/subdir).mkpath
      (include/"netgen"/subdir).install Dir.glob("libsrc/#{subdir}/*.{h,hpp}")
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include<iostream>
      namespace nglib {
          #include <nglib.h>
      }
      int main(int argc, char **argv) {
          nglib::Ng_Init();
          nglib::Ng_Mesh *mesh(nglib::Ng_NewMesh());
          nglib::Ng_DeleteMesh(mesh);
          nglib::Ng_Exit();
          return 0;
      }
    EOS
    system ENV.cxx, "-Wall", "-o", "test", "test.cpp",
           "-I#{include}", "-L#{lib}", "-lnglib", "-lTKIGES"
    system "./test"
  end
end
