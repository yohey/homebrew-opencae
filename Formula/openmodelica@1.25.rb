class OpenmodelicaAT125 < Formula
  desc "OpenModelica is an open-source Modelica-based modeling and simulation environment intended for industrial and academic usage."
  homepage "https://openmodelica.org"
  url "https://github.com/OpenModelica/OpenModelica.git", :using => :git, :tag => "v1.25.7"
  version "1.25.7"
  revision 2
  head "https://github.com/OpenModelica/OpenModelica.git"

  keg_only :versioned_formula

  depends_on "autoconf" => :build
  depends_on "cmake" => :build
  depends_on "ccache" => :build
  depends_on "gfortran" => :build
  depends_on "openjdk" => :build
  depends_on "pkg-config" => :build
  depends_on "sphinx-doc" => :build

  depends_on "boost"
  depends_on "libomp"
  depends_on "readline"
  depends_on "qt@6"

  depends_on "open-scene-graph"

  patch :DATA

  def install
    args = std_cmake_args + %w[
      -DCMAKE_C_COMPILER=/usr/bin/clang
      -DCMAKE_CXX_COMPILER=/usr/bin/clang++
      -DOM_QT_MAJOR_VERSION=6
      -DOM_OMEDIT_ENABLE_QTWEBENGINE=ON
    ]

    system "cmake", "-S", ".", "-B", "build_cmake", *args
    system "cmake", "--build", "build_cmake", "-j#{ENV.make_jobs}"
    system "cmake", "--install", "build_cmake"

    omedit_path = prefix/"Applications/OMEdit.app/Contents/MacOS/OMEdit"

    mv omedit_path, "#{omedit_path}.bin"

    omedit_path.write <<~EOS
      #!/bin/zsh
      set -euo pipefail

      export OPENMODELICALIBRARY="#{opt_lib/"omlibrary"}":${OPENMODELICALIBRARY:-}

      exec "#{omedit_path}.bin" "$@"
    EOS

    chmod 0755, omedit_path

    ln_s "../Applications/OMPlot.app/Contents/MacOS/OMPlot", bin/"OMPlot"
  end

  def post_install
    require "tmpdir"

    omlib = lib/"omlibrary"
    omlib.mkpath

    Dir.mktmpdir("openmodelica-postinstall-") do |tmp|
      tmp = Pathname(tmp)

      mos = tmp/"install_package.mos"
      mos.write <<~EOS
        updatePackageIndex();
        print(getErrorString());
        installPackage(Modelica, "4.1.0");
        print(getErrorString());
      EOS

      system "env", "HOME=#{tmp}", bin/"omc", mos

      (tmp/".openmodelica/libraries").children.each do |p|
        next unless p.extname == ".om"
        target = omlib/p.basename
        p.rename(target) unless target.exist?
      end
    end
  end

  def caveats
    appsdir = opt_prefix/"Applications"
    return unless appsdir.directory?

    apps = appsdir.children.select do |p|
      p.directory? && p.extname == ".app"
    end

    return if apps.empty?

    app_list = apps.sort_by(&:basename).map { |p| "  #{p}" }.join("\n")

    <<~EOS
      GUI apps were built and installed here:
      #{app_list}

      If you want to make them appear in Launchpad:
        mkdir -p /Applications/OpenModelica
        ln -s #{opt_prefix}/Applications/*.app /Applications/OpenModelica/
    EOS
  end

  test do
    assert_match "v#{version}-cmake", shell_output("#{prefix}/bin/omc --version 2>&1", 0)
  end
end

__END__
--- a/OMCompiler/3rdParty/zlib/zutil.h
+++ b/OMCompiler/3rdParty/zlib/zutil.h
@@ -135,10 +135,6 @@ extern z_const char * const z_errmsg[10]; /* indexed by 2-zlib_error */
 #  ifndef Z_SOLO
 #    if defined(__MWERKS__) && __dest_os != __be_os && __dest_os != __win32_os
 #      include <unix.h> /* for fdopen */
-#    else
-#      ifndef fdopen
-#        define fdopen(fd,mode) NULL /* No fdopen() */
-#      endif
 #    endif
 #  endif
 #endif
--- a/OMSimulator/3rdParty/zlib/zutil.h
+++ b/OMSimulator/3rdParty/zlib/zutil.h
@@ -142,10 +142,6 @@ extern z_const char * const z_errmsg[10]; /* indexed by 2-zlib_error */
 #  ifndef Z_SOLO
 #    if defined(__MWERKS__) && __dest_os != __be_os && __dest_os != __win32_os
 #      include <unix.h> /* for fdopen */
-#    else
-#      ifndef fdopen
-#        define fdopen(fd,mode) NULL /* No fdopen() */
-#      endif
 #    endif
 #  endif
 #endif
--- a/OMCompiler/3rdParty/FMIL/ThirdParty/Zlib/zlib-1.2.6/zutil.h
+++ b/OMCompiler/3rdParty/FMIL/ThirdParty/Zlib/zlib-1.2.6/zutil.h
@@ -123,10 +123,6 @@ extern const char * const z_errmsg[10]; /* indexed by 2-zlib_error */
 #  ifndef Z_SOLO
 #    if defined(__MWERKS__) && __dest_os != __be_os && __dest_os != __win32_os
 #      include <unix.h> /* for fdopen */
-#    else
-#      ifndef fdopen
-#        define fdopen(fd,mode) NULL /* No fdopen() */
-#      endif
 #    endif
 #  endif
 #endif
--- a/OMCompiler/SimulationRuntime/ModelicaExternalC/C-Sources/zlib/zutil.h
+++ b/OMCompiler/SimulationRuntime/ModelicaExternalC/C-Sources/zlib/zutil.h
@@ -135,10 +135,6 @@ extern z_const char * const z_errmsg[10]; /* indexed by 2-zlib_error */
 #  ifndef Z_SOLO
 #    if defined(__MWERKS__) && __dest_os != __be_os && __dest_os != __win32_os
 #      include <unix.h> /* for fdopen */
-#    else
-#      ifndef fdopen
-#        define fdopen(fd,mode) NULL /* No fdopen() */
-#      endif
 #    endif
 #  endif
 #endif
--- a/OMCompiler/SimulationRuntime/cpp/Core/Utils/extension/impl/factory.hpp
+++ b/OMCompiler/SimulationRuntime/cpp/Core/Utils/extension/impl/factory.hpp
@@ -39,7 +39,7 @@ public:
   factory(factory<T> const& first) : func(first.func) {}
 
   factory& operator=(factory<T> const& first) {
-    this->func = first->func;
+    this->func = first.func;
     return *this;
   }
 
