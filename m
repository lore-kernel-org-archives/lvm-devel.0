From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 16 Feb 2015 14:33:22 +0000 (UTC)
Subject: master - NIX: Fix CentOS builds.
Message-ID: <20150216143322.7E78261183@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=78d7466713a71c37fd241b5b2a9419c9914a7690
Commit:        78d7466713a71c37fd241b5b2a9419c9914a7690
Parent:        df28c4d912709667e743f5c9ab8974feeb37eafe
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Mon Feb 16 15:29:29 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Mon Feb 16 15:32:01 2015 +0100

NIX: Fix CentOS builds.

---
 nix/default.nix |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index e0c9499..c5f044f 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -189,7 +189,7 @@ let
                "cifs" "virtio_net" "unix" "hmac" "md4" "ecb" "des_generic" "sha256"
                "ata_piix" "sd_mod" ];
 
-  centos_url = ver: arch: if ver == "6.5" || ver == "7"
+  centos_url = ver: arch: if ver == "6.6" || ver == "7"
        then "http://ftp.fi.muni.cz/pub/linux/centos/${ver}/os/${arch}/"
        else "http://vault.centos.org/${ver}/os/${arch}/";
   fedora_url = ver: arch: if lib.eqStrings ver "rawhide" || lib.eqStrings ver "19"
@@ -276,6 +276,16 @@ let
         sha="3353e378f5cb4bb6c3b3dd2ca266c6d68a1e29c36cf99f76aea3d8e158626024";
       };
 
+      centos66i386 = centos {
+        version="6.6"; arch="i386";
+        sha="a8b935fcac1c8515c6d8dab3c43c53b3e461f89eb7a93b1914303784e28fcd17";
+      };
+
+      centos66x86_64 = centos {
+        version="6.6"; arch="x86_64";
+        sha="7651b16a9a2a8a5fbd0ad3ff8bbbe6f2409a64850ccfd83a6a3f874f13d8622f";
+      };
+
       centos70x86_64 = centos {
         version="7"; arch="x86_64";
         sha="1a7dd0d315b39ad504f54ea88676ab502a48064cb2d875ae3ae29431e175861c";
@@ -303,9 +313,10 @@ let
                  "perl-GD" # for lcov
                  "kernel"
                ];
-      centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "valgrind-devel" ];
-      centos64 = centos63;
+      centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" "valgrind-devel" "procps" ];
+      centos64 = centos63 ++ [ "corosynclib-devel" ];
       centos65 = centos64;
+      centos66 = centos65;
       centos70 = [ "dlm-devel" "dlm" "corosynclib-devel" "perl-Digest-MD5" "systemd-devel"
                    "procps-ng" "valgrind-devel" ];
 
@@ -359,6 +370,8 @@ let
     centos64_x86_64 = { arch = "x86_64" ; image = "centos64"; };
     centos65_i386   = { arch = "i386"  ; image = "centos65"; };
     centos65_x86_64 = { arch = "x86_64" ; image = "centos65"; };
+    centos66_i386   = { arch = "i386"  ; image = "centos66"; };
+    centos66_x86_64 = { arch = "x86_64" ; image = "centos66"; };
 
     centos70_x86_64 = { arch = "x86_64" ; image = "centos70"; };
 


