From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:12 +0000 (UTC)
Subject: master - NIX: Add CentOS 6.5 builds.
Message-ID: <20140228102612.567EB60F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb2c6fffe15620e4c26e6a108ab2ff82b035a4b4
Commit:        fb2c6fffe15620e4c26e6a108ab2ff82b035a4b4
Parent:        31e8fa883d345d897d50abdcc880345116cfacd2
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jan 8 16:35:55 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

NIX: Add CentOS 6.5 builds.

---
 release.nix |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/release.nix b/release.nix
index 5e4b3cf..0973bc2 100644
--- a/release.nix
+++ b/release.nix
@@ -42,7 +42,9 @@ let
   rootmods = [ "virtio_pci" "virtio_blk" "virtio_balloon" "ext4" "unix"
                "cifs" "virtio_net" "unix" "hmac" "md4" "ecb" "des_generic" "sha256" ];
 
-  centos_url = ver: arch: "http://vault.centos.org/${ver}/os/${arch}/";
+  centos_url = ver: arch: if ver == "6.5"
+       then "http://ftp.fi.muni.cz/pub/linux/centos/${ver}/os/${arch}/"
+       else "http://vault.centos.org/${ver}/os/${arch}/";
   fedora_url = ver: arch: if pkgs.lib.eqStrings ver "rawhide" || pkgs.lib.eqStrings ver "19"
                        then "ftp://ftp.fi.muni.cz/pub/linux/fedora/linux/development/${ver}/${arch}/os/"
                        else "mirror://fedora/linux/releases/${ver}/Everything/${arch}/os/";
@@ -114,6 +116,16 @@ let
         version="6.4"; arch="i386";
         sha="87aa4c4e19f9a3ec93e3d820f1ea6b6ece8810cb45f117a16354465e57a1b50d";
       };
+
+      centos65i386 = centos {
+        version="6.5"; arch="i386";
+        sha="a89f27cc7d3cea431f3bd605a1e9309c32d5d409abc1b51a7b5c71c05f18a0c2";
+      };
+
+      centos65x86_64 = centos {
+        version="6.5"; arch="x86_64";
+        sha="3353e378f5cb4bb6c3b3dd2ca266c6d68a1e29c36cf99f76aea3d8e158626024";
+      };
     };
 
   vm = pkgs: xmods: with pkgs.lib; rec {
@@ -137,6 +149,7 @@ let
                ];
       centos63 = [ "clusterlib-devel" "openaislib-devel" "cman" "libudev-devel" ];
       centos64 = centos63;
+      centos65 = centos64;
       fedora16 = [ "clusterlib-devel" "openaislib-devel" "cman" "systemd-devel" "libudev-devel" ];
       fedora17 = [ "dlm-devel" "corosynclib-devel" "device-mapper-persistent-data"
                    "dlm" "systemd-devel" "perl-Digest-MD5" "libudev-devel" ];
@@ -150,7 +163,7 @@ let
 
   mkRPM = { arch, image }: with pkgs.lib;
     let use = vm (if eqStrings arch "i386" then pkgs.pkgsi686Linux else pkgs)
-                 (if eqStrings image "centos64" then [] else [ "9p" "9pnet_virtio" ]);
+                 (if image == "centos64" || image == "centos65" then [] else [ "9p" "9pnet_virtio" ]);
      in mkVM {
            VM = use.rpmbuild;
            diskFun = builtins.getAttr "${image}${arch}" use.imgs;
@@ -217,6 +230,8 @@ let
     #centos63_x86_64 = mkRPM { arch = "x86_64" ; image = "centos63"; };
     centos64_i386 = mkRPM { arch = "i386"  ; image = "centos64"; };
     centos64_x86_64 = mkRPM { arch = "x86_64" ; image = "centos64"; };
+    centos65_i386 = mkRPM { arch = "i386"  ; image = "centos65"; };
+    centos65_x86_64 = mkRPM { arch = "x86_64" ; image = "centos65"; };
 
     rawhide_i386 = mkRPM { arch = "i386"  ; image = "rawhide"; };
     rawhide_x86_64 = mkRPM { arch = "x86_64" ; image = "rawhide"; };


