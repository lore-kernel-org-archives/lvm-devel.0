From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:46 +0000 (UTC)
Subject: master - NIX: Add a CentOS 7.0 64b build.
Message-ID: <20150205134346.B1D7E60FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ba05212f75b2e519c10b5758f3526cb8ca8f947
Commit:        6ba05212f75b2e519c10b5758f3526cb8ca8f947
Parent:        4686b8cea57d0c36759b73a5448e6c0f99405132
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 13 09:18:23 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:06 2015 +0100

NIX: Add a CentOS 7.0 64b build.

---
 nix/default.nix |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index 603b3dc..4d7c38a 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -39,7 +39,7 @@ let
          export PATH=/usr/bin:/bin:/usr/sbin:/sbin
 
          # we always run in a fresh image, so need to install everything again
-         ls ${build}/rpms/*/*.rpm | grep -v sysvinit | xargs rpm -Uv # */
+         ls ${build}/rpms/*/*.rpm | grep -v sysvinit | xargs rpm -Uv --oldpackage # */
          rpm -Uv ${pkgs.fetchurl {
             url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/16/i386/lcov-1.9-2.fc16.noarch.rpm";
             sha256 = "0ycdh5mb7p5ll76mqk0p6gpnjskvxxgh3a3bfr1crh94nvpwhp4z"; }}
@@ -181,7 +181,7 @@ let
                "cifs" "virtio_net" "unix" "hmac" "md4" "ecb" "des_generic" "sha256"
                "ata_piix" "sd_mod" ];
 
-  centos_url = ver: arch: if ver == "6.5"
+  centos_url = ver: arch: if ver == "6.5" || ver == "7"
        then "http://ftp.fi.muni.cz/pub/linux/centos/${ver}/os/${arch}/"
        else "http://vault.centos.org/${ver}/os/${arch}/";
   fedora_url = ver: arch: if lib.eqStrings ver "rawhide" || lib.eqStrings ver "19"
@@ -267,6 +267,11 @@ let
         version="6.5"; arch="x86_64";
         sha="3353e378f5cb4bb6c3b3dd2ca266c6d68a1e29c36cf99f76aea3d8e158626024";
       };
+
+      centos70x86_64 = centos {
+        version="7"; arch="x86_64";
+        sha="1a7dd0d315b39ad504f54ea88676ab502a48064cb2d875ae3ae29431e175861c";
+      };
     };
 
   vm = { pkgs, xmods, dmmods ? false }: with lib; rec {
@@ -307,6 +312,8 @@ let
       fedora20 = fedora19;
       fedora20u = fedora20;
 
+      centos70 = fedora20;
+
       rawhide = fedora20;
     };
 
@@ -348,6 +355,8 @@ let
     centos65_i386   = { arch = "i386"  ; image = "centos65"; };
     centos65_x86_64 = { arch = "x86_64" ; image = "centos65"; };
 
+    centos70_x86_64 = { arch = "x86_64" ; image = "centos70"; };
+
     rawhide_i386   = { arch = "i386"  ; image = "rawhide"; };
     rawhide_x86_64 = { arch = "x86_64" ; image = "rawhide"; };
   };


