From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:51 +0000 (UTC)
Subject: master - NIX: Allow adding/overriding test configurations.
Message-ID: <20150205134351.0F58860FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57c39ecbcd6b97643f99427dfe426cc20c1acd66
Commit:        57c39ecbcd6b97643f99427dfe426cc20c1acd66
Parent:        7c9d690f9e5a5490d7288441a813180eff2e20a2
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jan 14 17:28:44 2015 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:07 2015 +0100

NIX: Allow adding/overriding test configurations.

---
 nix/default.nix |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 4193354..cd92b91 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -4,11 +4,13 @@
   fc20_32_updates ? "", fc20_64_updates ? "",
   fc19_32_updates ? "", fc19_64_updates ? "",
   fc18_32_updates ? "", fc18_64_updates ? "",
-  T ? "", ENV ? "", timeout ? 60 }:
+  T ? "", ENV ? "", timeout ? 60,
+  overrides ? { pkgs }: { install_rpms = {}; distros = {}; configs = {}; } }:
 
 let
   pkgs = import nixpkgs {};
   lib = pkgs.lib;
+  over = overrides { inherit pkgs; };
 
   mkTest = args: pkgs.stdenv.mkDerivation rec {
      name = "lvm2-test-${(args.diskFun {}).name}";
@@ -189,7 +191,8 @@ let
                        then "ftp://ftp.fi.muni.cz/pub/linux/fedora/linux/development/${ver}/${arch}/os/"
                        else "mirror://fedora/linux/releases/${ver}/Everything/${arch}/os/";
   fedora_update_url = ver: arch: "mirror://fedora/linux/updates/${ver}/${arch}";
-  extra_distros = with lib; let
+
+  distros = with lib; let
       centos = { version, sha, arch }: {
         name = "centos-${version}-${arch}";
         fullName = "CentOS ${version} (${arch})";
@@ -273,7 +276,7 @@ let
         version="7"; arch="x86_64";
         sha="1a7dd0d315b39ad504f54ea88676ab502a48064cb2d875ae3ae29431e175861c";
       };
-    };
+    } // over.distros;
 
   vm = { pkgs, xmods, dmmods ? false }: with lib; rec {
     tools = import "${nixpkgs}/pkgs/build-support/vm/default.nix" {
@@ -283,12 +286,12 @@ let
     release = import "${nixpkgs}/pkgs/build-support/release/default.nix" {
       pkgs = pkgs // { vmTools = tools; }; };
     imgs = tools.diskImageFuns //
-            mapAttrs (n: a: b: pkgs.vmTools.makeImageFromRPMDist (a // b)) extra_distros;
-    rpmdistros = tools.rpmDistros // extra_distros;
+            mapAttrs (n: a: b: pkgs.vmTools.makeImageFromRPMDist (a // b)) distros;
+    rpmdistros = tools.rpmDistros // distros;
     rpmbuild = tools.buildRPM;
   };
 
-  extra_rpms = rec {
+  install_rpms = rec {
       common = [ "libselinux-devel" "libsepol-devel" "ncurses-devel" "readline-devel"
                  "corosynclib-devel"
                  "valgrind" "valgrind-devel" "gdb" "strace"
@@ -316,7 +319,7 @@ let
       centos70 = fedora20;
 
       rawhide = fedora20;
-    };
+    } // over.install_rpms;
 
   wrapper = fun: { arch, image, build ? {}, istest ? false }: with lib;
     let use = vm { pkgs = if eqStrings arch "i386" then pkgs.pkgsi686Linux else pkgs;
@@ -327,7 +330,7 @@ let
            inherit build istest;
            VM = use.rpmbuild;
            diskFun = builtins.getAttr "${image}${arch}" use.imgs;
-           extras = extra_rpms.common ++ builtins.getAttr image extra_rpms;
+           extras = install_rpms.common ++ builtins.getAttr image install_rpms;
            vmtools = use.tools;
            kernel = use.tools.makeKernelFromRPMDist (builtins.getAttr "${image}${arch}" use.rpmdistros);
         };
@@ -360,7 +363,7 @@ let
 
     rawhide_i386   = { arch = "i386"  ; image = "rawhide"; };
     rawhide_x86_64 = { arch = "x86_64" ; image = "rawhide"; };
-  };
+  } // over.configs;
 
   rpms = lib.mapAttrs (n: v: wrapper mkBuild v) configs;
   tests = let make = n: v: wrapper mkTest (v // { build = builtins.getAttr n rpms; istest = true; });


