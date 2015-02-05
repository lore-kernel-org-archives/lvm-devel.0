From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:01 +0000 (UTC)
Subject: master - NIX: Use nixpkgs kernel for building, distro kernel for testing.
Message-ID: <20150205134201.18E2C6036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6380869f27bfd4f271cb1c8ba3d023e1c94f77fd
Commit:        6380869f27bfd4f271cb1c8ba3d023e1c94f77fd
Parent:        2b6f9152ccbc74ab4c599089dc6bf0ae43ccd123
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Jun 28 11:16:46 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

NIX: Use nixpkgs kernel for building, distro kernel for testing.

---
 nix/default.nix |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 843440e..b6a4f98 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -229,10 +229,11 @@ let
       };
     };
 
-  vm = pkgs: xmods: with lib; rec {
+  vm = { pkgs, xmods, dmmods ? false }: with lib; rec {
     tools = import "${nixpkgs}/pkgs/build-support/vm/default.nix" {
       inherit pkgs; rootModules = rootmods ++ xmods ++
-        [ "loop" "dm_mod" "dm_snapshot" "dm_mirror" "dm_zero" "dm_raid" "dm_thin_pool" ]; };
+        (if dmmods then [ "loop" "dm_mod" "dm_snapshot" "dm_mirror" "dm_zero" "dm_raid" "dm_thin_pool" ]
+                   else []); };
     release = import "${nixpkgs}/pkgs/build-support/release/default.nix" {
       pkgs = pkgs // { vmTools = tools; }; };
     imgs = tools.diskImageFuns //
@@ -262,11 +263,13 @@ let
       rawhide = fedora19;
     };
 
-  wrapper = fun: { arch, image, build ? {} }: with lib;
-    let use = vm (if eqStrings arch "i386" then pkgs.pkgsi686Linux else pkgs)
-                 (if image == "centos64" || image == "centos65" then [] else [ "9p" "9pnet_virtio" ]);
+  wrapper = fun: { arch, image, build ? {}, istest ? false }: with lib;
+    let use = vm { pkgs = if eqStrings arch "i386" then pkgs.pkgsi686Linux else pkgs;
+                   xmods = if istest && (image == "centos64" || image == "centos65")
+                              then [] else [ "9p" "9pnet_virtio" ];
+                   dmmods = istest; };
      in fun {
-           inherit build;
+           inherit build istest;
            VM = use.rpmbuild;
            diskFun = builtins.getAttr "${image}${arch}" use.imgs;
            extras = extra_rpms.common ++ builtins.getAttr image extra_rpms;
@@ -301,7 +304,8 @@ let
   };
 
   rpms = lib.mapAttrs (n: v: wrapper mkBuild v) configs;
-  tests = lib.mapAttrs (n: v: wrapper mkTest (v // { build = builtins.getAttr n rpms; })) configs;
+  tests = let make = n: v: wrapper mkTest (v // { build = builtins.getAttr n rpms; istest = true; });
+           in lib.mapAttrs make configs;
 
   jobs = tests // {
     tarball = pkgs.releaseTools.sourceTarball rec {


