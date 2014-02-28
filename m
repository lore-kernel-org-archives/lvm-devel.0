From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:09 +0000 (UTC)
Subject: master - NIX: Adapt to use of 9P in VM builds.
Message-ID: <20140228102509.80DB860CD6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5fbccab21fda0b829e55be7d5045f1dbae1e811
Commit:        c5fbccab21fda0b829e55be7d5045f1dbae1e811
Parent:        9716af8c14655c364b7924170efee7e347836aaa
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 22 13:32:43 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

NIX: Adapt to use of 9P in VM builds.

---
 release.nix |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/release.nix b/release.nix
index 334a19f..503c1f0 100644
--- a/release.nix
+++ b/release.nix
@@ -26,8 +26,7 @@ let
      '';
    };
 
-  rootmods = [ "cifs" "virtio_net" "virtio_pci" "virtio_blk" "virtio_balloon" "nls_utf8" "ext2" "ext3"
-      "unix" "hmac" "md4" "ecb" "des_generic" ];
+  rootmods = [ "virtio_pci" "virtio_blk" "virtio_balloon" "ext4" "unix" "9p" "9pnet_virtio" ];
 
   centos_url = ver: arch: "http://ftp.fi.muni.cz/pub/linux/centos/${ver}/os/${arch}/";
   fedora_url = ver: arch: if pkgs.lib.eqStrings ver "rawhide" || pkgs.lib.eqStrings ver "19"


