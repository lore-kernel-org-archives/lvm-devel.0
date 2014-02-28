From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:30 +0000 (UTC)
Subject: master - NIX: Fedora 19 is now stable. Add builds that include updates.
Message-ID: <20140228102530.6BA5960CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=adf262e0793c29d9c51250bb276c0cc4387a93b5
Commit:        adf262e0793c29d9c51250bb276c0cc4387a93b5
Parent:        39d00da752c42a8a72d124313a373eaaee94ab28
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Aug 27 02:10:58 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

NIX: Fedora 19 is now stable. Add builds that include updates.

---
 release.nix |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/release.nix b/release.nix
index 4fddf5e..357ac3c 100644
--- a/release.nix
+++ b/release.nix
@@ -1,6 +1,6 @@
 { nixpkgs ? <nixpkgs>, lvm2Src, release ? false,
   rawhide32 ? "" , rawhide64 ? "" ,
-  fc19_32 ? "" , fc19_64 ? "",
+  fc19_32_updates ? "", fc19_64_updates ? "",
   fc18_32_updates ? "", fc18_64_updates ? "",
   lvm2Nix ? lvm2Src, T ? "" }:
 
@@ -68,6 +68,7 @@ let
       '') { inherit fedora; };
       update = version: arch: repodata: orig: orig // (import (pkgs.runCommand "updates-fedora.nix" {} ''
           sha=$(grep primary.xml ${repodata} | sed -re 's:.* ([0-9a-f]+)-primary.*:\1:')
+          echo fedora ${version} updates sha: $sha
           (echo 'fetchurl: orig: { packagesLists = [ orig.packagesList ('
            echo "fetchurl { "
            echo "  url = \"${fedora_update_url version arch}/repodata/$sha-primary.xml.gz\";"
@@ -79,8 +80,8 @@ let
     in {
       rawhidex86_64 = rawhide "rawhide" "x86_64" rawhide64;
       rawhidei386 = rawhide "rawhide" "i386" rawhide32;
-      fedora19x86_64 = rawhide "19" "x86_64" fc19_64;
-      fedora19i386 = rawhide "19" "i386" fc19_32;
+      fedora19ux86_64 = update "19" "x86_64" fc19_64_updates pkgs.vmTools.rpmDistros.fedora19x86_64;
+      fedora19ui386 = update "19" "i386" fc19_32_updates pkgs.vmTools.rpmDistros.fedora19i386;
       fedora18ux86_64 = update "18" "x86_64" fc18_64_updates pkgs.vmTools.rpmDistros.fedora18x86_64;
       fedora18ui386 = update "18" "i386" fc18_32_updates pkgs.vmTools.rpmDistros.fedora18i386;
 
@@ -133,6 +134,7 @@ let
                    "dlm" "systemd-devel" "perl-Digest-MD5" ];
       fedora18u = fedora18;
       fedora19 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel" "procps-ng" ];
+      fedora19u = fedora19;
       rawhide = fedora19;
     };
 
@@ -197,7 +199,9 @@ let
     fc16_i386   = mkRPM { arch = "i386"  ; image = "fedora16"; };
 
     fc18u_x86_64 = mkRPM { arch = "x86_64"; image = "fedora18u"; };
-    fc18u_i386   = mkRPM { arch = "x86_64"; image = "fedora18u"; };
+    fc18u_i386   = mkRPM { arch = "i386"; image = "fedora18u"; };
+    fc19u_x86_64 = mkRPM { arch = "x86_64"; image = "fedora19u"; };
+    fc19u_i386   = mkRPM { arch = "i386"; image = "fedora19u"; };
 
     centos63_i386 = mkRPM { arch = "i386"  ; image = "centos63"; };
     centos63_x86_64 = mkRPM { arch = "x86_64" ; image = "centos63"; };


