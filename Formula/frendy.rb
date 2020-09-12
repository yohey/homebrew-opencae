# coding: utf-8
class Frendy < Formula
  desc "FRENDY：FRom Evaluated Nuclear Data librarY to any application"
  homepage "https://rpg.jaea.go.jp/main/ja/program_frendy/"
  url "http://rpg.jaea.go.jp/download/frendy_20191126.tar.gz"
  version "1.02.003"
  sha256 "2510e4767daa4624fe2934b7b2405d7a77fd25b0f74ee18dd5a47b2536749725"

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
