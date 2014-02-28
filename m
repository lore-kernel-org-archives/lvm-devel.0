From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:08 +0000 (UTC)
Subject: master - NIX: Use vault.centos.org to get older revisions.
Message-ID: <20140228102608.2883960F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55964cedcb1c58b5e258eb22ab99134d44c38678
Commit:        55964cedcb1c58b5e258eb22ab99134d44c38678
Parent:        cc6ed8fa66df4fba65a64b7111e26f5eb6b20162
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jan 8 15:35:12 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

NIX: Use vault.centos.org to get older revisions.

---
 release.nix |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/release.nix b/release.nix
index 8fa4168..a59ebb8 100644
--- a/release.nix
+++ b/release.nix
@@ -42,7 +42,7 @@ let
   rootmods = [ "virtio_pci" "virtio_blk" "virtio_balloon" "ext4" "unix"
                "cifs" "virtio_net" "unix" "hmac" "md4" "ecb" "des_generic" "sha256" ];
 
-  centos_url = ver: arch: "http://ftp.fi.muni.cz/pub/linux/centos/${ver}/os/${arch}/";
+  centos_url = ver: arch: "http://vault.centos.org/${ver}/os/${arch}/";
   fedora_url = ver: arch: if pkgs.lib.eqStrings ver "rawhide" || pkgs.lib.eqStrings ver "19"
                        then "ftp://ftp.fi.muni.cz/pub/linux/fedora/linux/development/${ver}/${arch}/os/"
                        else "mirror://fedora/linux/releases/${ver}/Everything/${arch}/os/";


