From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:07 +0000 (UTC)
Subject: master - NIX: Add Fedora 20 jobs.
Message-ID: <20150205134207.698096036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f96c310eea7e4f6a6cc567e2f5b52a2d1f5f4c90
Commit:        f96c310eea7e4f6a6cc567e2f5b52a2d1f5f4c90
Parent:        0abad40f416a3831c9e4b44924468bd7b591a4fa
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Jun 29 17:37:16 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:19 2015 +0100

NIX: Add Fedora 20 jobs.

---
 nix/default.nix |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 55ad8e1..c73ec29 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -1,5 +1,6 @@
 { nixpkgs ? <nixpkgs>, lvm2Src, release ? false,
   rawhide32 ? "" , rawhide64 ? "" ,
+  fc20_32_updates ? "", fc20_64_updates ? "",
   fc19_32_updates ? "", fc19_64_updates ? "",
   fc18_32_updates ? "", fc18_64_updates ? "",
   T ? "" }:
@@ -190,6 +191,8 @@ let
     in {
       rawhidex86_64 = rawhide "rawhide" "x86_64" rawhide64;
       rawhidei386 = rawhide "rawhide" "i386" rawhide32;
+      fedora20ux86_64 = update "20" "x86_64" fc20_64_updates pkgs.vmTools.rpmDistros.fedora20x86_64;
+      fedora20ui386 = update "20" "i386" fc20_32_updates pkgs.vmTools.rpmDistros.fedora20i386;
       fedora19ux86_64 = update "19" "x86_64" fc19_64_updates pkgs.vmTools.rpmDistros.fedora19x86_64;
       fedora19ui386 = update "19" "i386" fc19_32_updates pkgs.vmTools.rpmDistros.fedora19i386;
       fedora18ux86_64 = update "18" "x86_64" fc18_64_updates pkgs.vmTools.rpmDistros.fedora18x86_64;
@@ -252,12 +255,18 @@ let
       fedora16 = [ "clusterlib-devel" "openaislib-devel" "cman" "systemd-devel" "libudev-devel" ];
       fedora17 = [ "dlm-devel" "corosynclib-devel" "device-mapper-persistent-data"
                    "dlm" "systemd-devel" "perl-Digest-MD5" "libudev-devel" ];
+
       fedora18 = [ "dlm-devel" "corosynclib-devel" "device-mapper-persistent-data"
                    "dlm" "systemd-devel" "perl-Digest-MD5" ];
       fedora18u = fedora18;
+
       fedora19 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel" "procps-ng" ];
       fedora19u = fedora19;
-      rawhide = fedora19;
+
+      fedora20 = fedora19;
+      fedora20u = fedora20;
+
+      rawhide = fedora20;
     };
 
   wrapper = fun: { arch, image, build ? {}, istest ? false }: with lib;
@@ -275,6 +284,8 @@ let
         };
 
   configs = {
+    fc20_x86_64 = { arch = "x86_64"; image = "fedora20"; };
+    fc20_i386   = { arch = "i386"  ; image = "fedora20"; };
     fc19_x86_64 = { arch = "x86_64"; image = "fedora19"; };
     fc19_i386   = { arch = "i386"  ; image = "fedora19"; };
     fc18_x86_64 = { arch = "x86_64"; image = "fedora18"; };


