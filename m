From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:36 +0000 (UTC)
Subject: master - NIX: Restore CIFS modules, as 9p is broken on many kernels.
Message-ID: <20140228102536.BAC5160F97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9434611924962e10fb653c8ece93fc69c2ef593a
Commit:        9434611924962e10fb653c8ece93fc69c2ef593a
Parent:        5f60d53fccfa5224a61ec4ef21bce1004f1142b9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Aug 31 00:35:11 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

NIX: Restore CIFS modules, as 9p is broken on many kernels.

---
 release.nix |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index 357ac3c..49becd0 100644
--- a/release.nix
+++ b/release.nix
@@ -30,7 +30,8 @@ let
      '';
    };
 
-  rootmods = [ "virtio_pci" "virtio_blk" "virtio_balloon" "ext4" "unix" "9p" "9pnet_virtio" ];
+  rootmods = [ "virtio_pci" "virtio_blk" "virtio_balloon" "ext4" "unix" "9p" "9pnet_virtio"
+               "cifs" "virtio_net" "unix" "hmac" "md4" "ecb" "des_generic" "sha256" ];
 
   centos_url = ver: arch: "http://ftp.fi.muni.cz/pub/linux/centos/${ver}/os/${arch}/";
   fedora_url = ver: arch: if pkgs.lib.eqStrings ver "rawhide" || pkgs.lib.eqStrings ver "19"


