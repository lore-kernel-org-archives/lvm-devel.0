From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:38 +0000 (UTC)
Subject: master - NIX: Do not insmod 9p/virtfs on centos64 as it BUGs out right away.
Message-ID: <20140228102538.D83F760F97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4eaaad0caa339bd548a3b6ece830b682ed7e9033
Commit:        4eaaad0caa339bd548a3b6ece830b682ed7e9033
Parent:        9434611924962e10fb653c8ece93fc69c2ef593a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Aug 31 01:00:19 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

NIX: Do not insmod 9p/virtfs on centos64 as it BUGs out right away.

---
 release.nix |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/release.nix b/release.nix
index 49becd0..1a7183f 100644
--- a/release.nix
+++ b/release.nix
@@ -30,7 +30,7 @@ let
      '';
    };
 
-  rootmods = [ "virtio_pci" "virtio_blk" "virtio_balloon" "ext4" "unix" "9p" "9pnet_virtio"
+  rootmods = [ "virtio_pci" "virtio_blk" "virtio_balloon" "ext4" "unix"
                "cifs" "virtio_net" "unix" "hmac" "md4" "ecb" "des_generic" "sha256" ];
 
   centos_url = ver: arch: "http://ftp.fi.muni.cz/pub/linux/centos/${ver}/os/${arch}/";
@@ -107,9 +107,9 @@ let
       };
     };
 
-  vm = pkgs: with pkgs.lib; rec {
+  vm = pkgs: xmods: with pkgs.lib; rec {
     tools = import "${nixpkgs}/pkgs/build-support/vm/default.nix" {
-      inherit pkgs; rootModules = rootmods ++
+      inherit pkgs; rootModules = rootmods ++ xmods ++
         [ "loop" "dm_mod" "dm_snapshot" "dm_mirror" "dm_zero" "dm_raid" "dm_thin_pool" ]; };
     release = import "${nixpkgs}/pkgs/build-support/release/default.nix" {
       pkgs = pkgs // { vmTools = tools; }; };
@@ -140,7 +140,8 @@ let
     };
 
   mkRPM = { arch, image }: with pkgs.lib;
-    let use = if eqStrings arch "i386" then vm pkgs.pkgsi686Linux else vm pkgs;
+    let use = vm (if eqStrings arch "i386" then pkgs.pkgsi686Linux else pkgs)
+                 (if eqStrings image "centos64" then [] else [ "9p" "9pnet_virtio" ]);
      in mkVM {
            VM = use.rpmbuild;
            diskFun = builtins.getAttr "${image}${arch}" use.imgs;


