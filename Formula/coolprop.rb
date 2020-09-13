class Coolprop < Formula
  desc "Thermophysical properties for the masses"
  homepage "http://www.coolprop.org/"
  url "https://github.com/CoolProp/CoolProp.git", :using => :git, :tag => "v6.4.1"
  version "v6.4.1"
  head "https://github.com/CoolProp/CoolProp.git"

  keg_only ""

  option "with-static", "Enable static build"
  option "without-shared", "Disable shared build"

  depends_on "cmake" => :build

  def install
    args = std_cmake_args
    args << "-DCOOLPROP_RELEASE=ON"
    args << "-DCOOLPROP_INSTALL_PREFIX=#{prefix}"
    args << "-DCOOLPROP_OBJECT_LIBRARY=OFF"

    if build.with?("shared")
      mkdir "build-shared" do
        system "cmake", *args, "-DCOOLPROP_SHARED_LIBRARY=ON", "-DCOOLPROP_STATIC_LIBRARY=OFF", ".."
        system "make"
      end
    end

    if build.with?("static")
      mkdir "build-static" do
        system "cmake", *args, "-DCOOLPROP_SHARED_LIBRARY=OFF", "-DCOOLPROP_STATIC_LIBRARY=ON", ".."
        system "make"
      end
    end

    lib.install Dir["build-shared/libCoolProp.dylib"] if build.with?("shared")
    lib.install Dir["build-static/libCoolProp.a"]     if build.with?("static")
    include.install Dir["include/*.h"]
    (include/"fmt").mkpath
    (include/"fmt").install Dir["externals/fmtlib/fmt/*.h"]
  end

  # test do
  # end
end
