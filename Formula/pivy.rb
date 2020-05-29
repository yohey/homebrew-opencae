class PivyAT06 < Formula
  homepage "https://github.com/coin3d/pivy"
  url "https://github.com/coin3d/pivy/archive/0.6.5.tar.gz"
  sha256 "16f2e339e5c59a6438266abe491013a20f53267e596850efad1559564a2c1719"
  head "https://github.com/coin3d/pivy.git", :using => :git
  version "0.6.5"


  depends_on "cmake"   => :build
  depends_on "python@3.8" => :build
  depends_on "swig@3"  => :build
  depends_on "FreeCAD/freecad/coin"

  def install
    system "python3", "setup.py", "install", "--prefix=#{prefix}"
  end
end
