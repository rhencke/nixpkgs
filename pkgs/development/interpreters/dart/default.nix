{ stdenv, fetchurl, unzip }:

let
  version = "1.16.1";
  archives = {
    x86_64-linux = {
      dartsystem = "linux-x64";
      sha256 = "01cbnc8hd2wwprmivppmzvld9ps644k16wpgqv31h1596l5p82n2";
    };
    i686-linux = {
      dartsystem = "linux-ia32";
      sha256 = "0jfwzc3jbk4n5j9ka59s9bkb25l5g85fl1nf676mvj36swcfykx3";
    };
    x86_64-darwin = {
      dartsystem = "macos-x64";
      sha256 = "1airgw33f4426zggvfq3ryd1fsr7b0n1r0v195f87f6xg9y66nmi";
    };
  };
  archive = if archives ? "${stdenv.system}"
    then archives."${stdenv.system}"
    else throw "Unsupported system: ${stdenv.system}";
in
stdenv.mkDerivation {
  name = "dart-${version}";

  nativeBuildInputs = [
    unzip
  ];

  src = fetchurl {
    url = "https://storage.googleapis.com/dart-archive/channels/stable/release/${version}/sdk/dartsdk-${archive.dartsystem}-release.zip";
    sha256 = archive.sha256;
  };

  installPhase = ''
    mkdir -p $out
    cp -R bin include lib $out/
    echo $libPath
  '';

  postInstall = stdenv.lib.optionalString stdenv.isLinux ''
  patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
             --set-rpath $libPath \
             $out/bin/dart
  '';

  libPath = stdenv.lib.makeLibraryPath [ stdenv.cc.cc ];

  dontStrip = true;

  meta = {
    platforms = [ "i686-linux" "x86_64-linux" "x86_64-darwin" ];
    homepage = https://www.dartlang.org/;
    description = "Scalable programming language, with robust libraries and runtimes, for building web, server, and mobile apps";
    longDescription = ''
      Dart is a class-based, single inheritance, object-oriented language
      with C-style syntax. It offers compilation to JavaScript, interfaces,
      mixins, abstract classes, reified generics, and optional typing.
    '';
    license = stdenv.lib.licenses.bsd3;
  };
}
