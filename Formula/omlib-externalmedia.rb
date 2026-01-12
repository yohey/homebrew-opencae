class OmlibExternalmedia < Formula
  desc "The ExternalMedia library provides a framework for interfacing external codes computing fluid properties to Modelica.Media-compatible component models."
  homepage "https://github.com/modelica-3rdparty/ExternalMedia"
  url "https://github.com/modelica-3rdparty/ExternalMedia.git", :using => :git, :tag => "v4.1.1"
  version "4.1.1"
  revision 2
  head "https://github.com/modelica-3rdparty/ExternalMedia.git"

  depends_on "cmake" => :build

  depends_on "yohey/opencae/openmodelica@1.26"

  patch :DATA

  def install
    args = std_cmake_args + %w[
      -DCMAKE_C_COMPILER=/usr/bin/clang
      -DCMAKE_CXX_COMPILER=/usr/bin/clang++
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
    ]

    # The current version of ExternalMedia requires you to run the configure step twice.
    system "cmake", "-B", "build_cmake", "-S", "./Projects", *args
    system "cmake", "-B", "build_cmake", "-S", "./Projects", *args

    system "cmake", "--build", "build_cmake", "--config", "Release"
    system "cmake", "--build", "build_cmake", "--config", "Release", "--target", "install"

    system "mv", "Modelica/ExternalMedia", "Modelica/ExternalMedia #{version}"

    (lib/"omlibrary").mkpath
    (lib/"omlibrary").install Dir["Modelica/ExternalMedia #{version}"]

    if Hardware::CPU.arm?
      ln_s "aarch64-darwin", lib/"omlibrary/ExternalMedia #{version}/Resources/Library/arm64-darwin"
      ln_s "aarch64-darwin", lib/"omlibrary/ExternalMedia #{version}/Resources/Library/darwin64"
    end
  end

  # test do
  # end
end

__END__
--- a/Modelica/ExternalMedia/Media/BaseClasses/ExternalTwoPhaseMedium.mo
+++ b/Modelica/ExternalMedia/Media/BaseClasses/ExternalTwoPhaseMedium.mo
@@ -216,7 +216,7 @@ package ExternalTwoPhaseMedium "Generic external two phase medium package"
     input FixedPhase phase = 0
       "2 for two-phase, 1 for one-phase, 0 if not known";
     output ThermodynamicState state;
-    external "C" TwoPhaseMedium_setState_ph_C_impl_wrap(p, h, phase, state, mediumName, libraryName, substanceName)
+    external "C" TwoPhaseMedium_setState_ph_C_impl(p, h, phase, state, mediumName, libraryName, substanceName)
     annotation(Library="ExternalMediaLib", IncludeDirectory="modelica://ExternalMedia/Resources/Include", LibraryDirectory="modelica://ExternalMedia/Resources/Library",
     Include="
     #ifndef SETSTATE_PH_DEFINED
@@ -224,7 +224,7 @@ package ExternalTwoPhaseMedium "Generic external two phase medium package"
     #include \"externalmedialib.h\"
     #include \"ModelicaUtilities.h\"
     
-    void TwoPhaseMedium_setState_ph_C_impl_wrap(double p, double h, int phase, void *state, const char *mediumName, const char *libraryName, const char *substanceName)
+    void TwoPhaseMedium_setState_ph_C_impl(double p, double h, int phase, void *state, const char *mediumName, const char *libraryName, const char *substanceName)
     {
       TwoPhaseMedium_setState_ph_C_impl_err(p, h, phase, state, mediumName, libraryName, substanceName, ModelicaError,ModelicaWarning);
     }
@@ -240,7 +240,7 @@ package ExternalTwoPhaseMedium "Generic external two phase medium package"
     input FixedPhase phase = 0
       "2 for two-phase, 1 for one-phase, 0 if not known";
     output ThermodynamicState state;
-    external "C" TwoPhaseMedium_setState_pT_C_impl_wrap(p, T, state, mediumName, libraryName, substanceName)
+    external "C" TwoPhaseMedium_setState_pT_C_impl(p, T, state, mediumName, libraryName, substanceName)
     annotation(Library="ExternalMediaLib", IncludeDirectory="modelica://ExternalMedia/Resources/Include", LibraryDirectory="modelica://ExternalMedia/Resources/Library",
     Include="
     #ifndef SETSTATE_PT_DEFINED
@@ -248,7 +248,7 @@ package ExternalTwoPhaseMedium "Generic external two phase medium package"
     #include \"externalmedialib.h\"
     #include \"ModelicaUtilities.h\"
     
-    void TwoPhaseMedium_setState_pT_C_impl_wrap(double p, double T, void *state, const char *mediumName, const char *libraryName, const char *substanceName)
+    void TwoPhaseMedium_setState_pT_C_impl(double p, double T, void *state, const char *mediumName, const char *libraryName, const char *substanceName)
     {
       TwoPhaseMedium_setState_pT_C_impl_err(p, T, state, mediumName, libraryName, substanceName, ModelicaError, ModelicaWarning);
     }
@@ -277,7 +277,7 @@ package ExternalTwoPhaseMedium "Generic external two phase medium package"
     input FixedPhase phase = 0
       "2 for two-phase, 1 for one-phase, 0 if not known";
     output ThermodynamicState state;
-    external "C" TwoPhaseMedium_setState_dT_C_impl_wrap(d, T, phase, state, mediumName, libraryName, substanceName)
+    external "C" TwoPhaseMedium_setState_dT_C_impl(d, T, phase, state, mediumName, libraryName, substanceName)
     annotation(Library="ExternalMediaLib", IncludeDirectory="modelica://ExternalMedia/Resources/Include", LibraryDirectory="modelica://ExternalMedia/Resources/Library",
     Include="
     #ifndef SETSTATE_DT_DEFINED
@@ -285,7 +285,7 @@ package ExternalTwoPhaseMedium "Generic external two phase medium package"
     #include \"externalmedialib.h\"
     #include \"ModelicaUtilities.h\"
     
-    void TwoPhaseMedium_setState_dT_C_impl_wrap(double d, double T, int phase, void *state, const char *mediumName, const char *libraryName, const char *substanceName)
+    void TwoPhaseMedium_setState_dT_C_impl(double d, double T, int phase, void *state, const char *mediumName, const char *libraryName, const char *substanceName)
     {
       TwoPhaseMedium_setState_dT_C_impl_err(d, T, phase, state, mediumName, libraryName, substanceName, &ModelicaError, &ModelicaWarning);
     }
@@ -301,7 +301,7 @@ package ExternalTwoPhaseMedium "Generic external two phase medium package"
     input FixedPhase phase = 0
       "2 for two-phase, 1 for one-phase, 0 if not known";
     output ThermodynamicState state;
-    external "C" TwoPhaseMedium_setState_ps_C_impl_wrap(p, s, phase, state, mediumName, libraryName, substanceName)
+    external "C" TwoPhaseMedium_setState_ps_C_impl(p, s, phase, state, mediumName, libraryName, substanceName)
     annotation(Library="ExternalMediaLib", IncludeDirectory="modelica://ExternalMedia/Resources/Include", LibraryDirectory="modelica://ExternalMedia/Resources/Library",
     Include="
     #ifndef SETSTATE_PS_DEFINED
@@ -309,7 +309,7 @@ package ExternalTwoPhaseMedium "Generic external two phase medium package"
     #include \"externalmedialib.h\"
     #include \"ModelicaUtilities.h\"
     
-    void TwoPhaseMedium_setState_ps_C_impl_wrap(double p, double s, int phase, void *state, const char *mediumName, const char *libraryName, const char *substanceName)
+    void TwoPhaseMedium_setState_ps_C_impl(double p, double s, int phase, void *state, const char *mediumName, const char *libraryName, const char *substanceName)
     {
       TwoPhaseMedium_setState_ps_C_impl_err(p, s, phase, state, mediumName, libraryName, substanceName, &ModelicaError, &ModelicaWarning);
     }
@@ -325,7 +325,7 @@ package ExternalTwoPhaseMedium "Generic external two phase medium package"
     input FixedPhase phase = 0
       "2 for two-phase, 1 for one-phase, 0 if not known";
     output ThermodynamicState state;
-    external "C" TwoPhaseMedium_setState_hs_C_impl_wrap(h, s, phase, state, mediumName, libraryName, substanceName)
+    external "C" TwoPhaseMedium_setState_hs_C_impl(h, s, phase, state, mediumName, libraryName, substanceName)
     annotation(Library="ExternalMediaLib", IncludeDirectory="modelica://ExternalMedia/Resources/Include", LibraryDirectory="modelica://ExternalMedia/Resources/Library",
     Include="
     #ifndef SETSTATE_HS_DEFINED
@@ -333,7 +333,7 @@ package ExternalTwoPhaseMedium "Generic external two phase medium package"
     #include \"externalmedialib.h\"
     #include \"ModelicaUtilities.h\"
     
-    void TwoPhaseMedium_setState_hs_C_impl_wrap(double h, double s, int phase, void *state, const char *mediumName, const char *libraryName, const char *substanceName)
+    void TwoPhaseMedium_setState_hs_C_impl(double h, double s, int phase, void *state, const char *mediumName, const char *libraryName, const char *substanceName)
     {
       TwoPhaseMedium_setState_hs_C_impl_err(h, s, phase, state, mediumName, libraryName, substanceName, &ModelicaError, &ModelicaWarning);
     }
