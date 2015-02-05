From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:30 +0000 (UTC)
Subject: master - NIX: Some kernels need ide/ata modules (i.e. no builtin ata).
Message-ID: <20150205134230.BD315601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2dbf441165f998cf2adf96995a58e978e0c9473
Commit:        e2dbf441165f998cf2adf96995a58e978e0c9473
Parent:        eaa9f3554057aafd2e521aed12c9918b71501a0d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 21 03:56:34 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

NIX: Some kernels need ide/ata modules (i.e. no builtin ata).

---
 nix/default.nix |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/nix/default.nix b/nix/default.nix
index fb386e8..20922b8 100644
--- a/nix/default.nix
+++ b/nix/default.nix
@@ -152,7 +152,8 @@ let
    };
 
   rootmods = [ "virtio_pci" "virtio_blk" "virtio_balloon" "ext4" "unix"
-               "cifs" "virtio_net" "unix" "hmac" "md4" "ecb" "des_generic" "sha256" ];
+               "cifs" "virtio_net" "unix" "hmac" "md4" "ecb" "des_generic" "sha256"
+               "ata_piix" "sd_mod" ];
 
   centos_url = ver: arch: if ver == "6.5"
        then "http://ftp.fi.muni.cz/pub/linux/centos/${ver}/os/${arch}/"


