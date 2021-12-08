# coding: utf-8
class Frendy < Formula
  desc "FRENDY：FRom Evaluated Nuclear Data librarY to any application"
  homepage "https://rpg.jaea.go.jp/main/ja/program_frendy/"
  url "https://rpg.jaea.go.jp/download/frendy/frendy_20201203.tar.gz"
  version "1.03.007"
  sha256 "9235b2d7e30aed483d5caf95f49b41bd8c2848e44517c16f94969addeabc5339"

  depends_on "openblas"

  def install
    ENV.cxx11

    target               = "frendy"
    lib_frendy           = "libfrendy.a"
    target_njoy_mode     = "frendy_njoy_mode"
    lib_frendy_njoy_mode = "libfrendy_njoy_mode.a"

    cd "frendy/main" do
      system "make", "TARGET=#{target}", "LIB_FRENDY=#{lib_frendy}"
      bin.install Dir[target]
      lib.install Dir[lib_frendy]
    end

    cd "frendy/main_njoy_mode" do
      system "make", "TARGET=#{target_njoy_mode}", "LIB_FRENDY=#{lib_frendy_njoy_mode}"
      bin.install Dir[target_njoy_mode]
      lib.install Dir[lib_frendy_njoy_mode]
    end

    share.install Dir["sample"]
    share.install Dir["tests"]
    share.install Dir["tools"]
  end

  # test do
  # end
end
