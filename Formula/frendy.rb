# coding: utf-8
class Frendy < Formula
  desc "FRENDY：FRom Evaluated Nuclear Data librarY to any application"
  homepage "https://rpg.jaea.go.jp/main/ja/program_frendy/"
  url "https://rpg.jaea.go.jp/download/frendy/frendy_20220126.tar.gz"
  version "2.00.000"
  sha256 "3ccea84e46291e2509fb1da7a412d5607afe3802cdd6b4caf7860f70643ed2e6"

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
