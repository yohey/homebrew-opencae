class Cea2 < Formula
  desc "Chemical Equilibrium with Applications"
  homepage "https://www1.grc.nasa.gov/research-and-engineering/ceaweb/"
  version "2004.05.21"
  url "https://raw.githubusercontent.com/sonofeft/RocketCEA/1.0.1/NASA_CEA_Fortran/cea2.f"
  sha256 "82eed4b4c7eed238cacaf209d809daa2087ac52c4153efeafea0496b4a385921"

  depends_on "gfortran" => :build

  resource "cea.inc" do
    url "https://raw.githubusercontent.com/sonofeft/RocketCEA/1.0.1/NASA_CEA_Fortran/cea.inc"
    sha256 "6007d96cfc14ebe146101a5671e5f3dc52969837081351db06f8600be9cafff9"
  end

  resource "thermo.inp" do
    url "https://raw.githubusercontent.com/sonofeft/RocketCEA/1.0.1/NASA_CEA_Fortran/thermo.inp"
    sha256 "dd6aaac2a87b57f7b70f2efe907cb33aedc351dae622cf807a96db8b0b0faa5f"
  end

  resource "trans.inp" do
    url "https://raw.githubusercontent.com/sonofeft/RocketCEA/1.0.1/NASA_CEA_Fortran/trans.inp"
    sha256 "77de02c1393a05848359bf546f6af96e06f50e9d4c7798ebdd06c75c78949a69"
  end

  resource "cea2.inp" do
    url "https://raw.githubusercontent.com/sonofeft/RocketCEA/1.0.1/NASA_CEA_Fortran/cea2.inp"
    sha256 "6b95ac49750573cbb527d7ea0fc3211eb1c108cc300d6b420ab7fe1a852393a5"
  end

  resource "cea2.out" do
    url "https://raw.githubusercontent.com/sonofeft/RocketCEA/1.0.1/NASA_CEA_Fortran/cea2.out"
    sha256 "ca19dc06ca3638000f7d0d86ac2e4da16d51378cf40e34422da0bc4c8dfa2801"
  end

  def install
    resource("cea.inc").stage buildpath
    resource("thermo.inp").stage buildpath
    resource("trans.inp").stage buildpath

    fortran = "#{Formula["gfortran"].opt_bin}/gfortran"

    system fortran, "-o", "cea2", "cea2.f"

    Utils.safe_popen_write("./cea2") do |stdin|
      stdin.puts "thermo"
    end

    Utils.safe_popen_write("./cea2") do |stdin|
      stdin.puts "trans"
    end

    bin.install "cea2"
    lib.install "thermo.lib"
    lib.install "trans.lib"
  end

  test do
    resource("cea2.inp").stage testpath
    resource("cea2.out").stage testpath/"orig"

    ln_s lib/"thermo.lib", testpath/"thermo.lib"
    ln_s lib/"trans.lib", testpath/"trans.lib"

    require "open3"

    Open3.popen3(bin/"cea2") do |stdin, stdout, stderr, wait_thr|
      stdin.puts "cea2"
      stdout.read rescue nil
      stderr.read rescue nil
      assert_equal 0, wait_thr.value.exitstatus
    end

    system "diff", testpath/"orig/cea2.out", testpath/"cea2.out"
  end
end
