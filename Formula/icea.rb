class Icea < Formula
  desc "Interface-extended CEA"
  url "https://github.com/yohey/icea.git", :tag => "v0.2.2"
  version "v0.2.2"
  head "https://github.com/yohey/icea.git", :branch => "main"

  depends_on "cmake" => :build
  depends_on "gfortran" => :build

  def install
    ENV.deparallelize
    system "cmake", "-S", ".", "-B", "Build", *std_cmake_args
    system "cmake", "--build", "Build"
    system "cmake", "--install", "Build"
  end

  def caveats
    <<~EOS
      For python to import icea you may need to set:
        export PYTHONPATH="/opt/homebrew/opt/icea/lib"
    EOS
  end

  test do
    system "cmake", "--build", "Build", "--target", "test"
  end
end
