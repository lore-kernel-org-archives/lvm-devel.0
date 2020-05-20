From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 May 2020 14:03:24 +0000 (GMT)
Subject: master - tests: add wait on udev processing
Message-ID: <20200520140324.84C74395CC20@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d3b515cea54bae28c438eeef77cd3625d9b2a00c
Commit:        d3b515cea54bae28c438eeef77cd3625d9b2a00c
Parent:        deb51601818ec9d2f9a29205896125c82cf6ce00
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 15 16:56:40 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 20 16:01:20 2020 +0200

tests: add wait on udev processing

Trying to avoid collision with udev watch rule preventing to
succeed 'dmsetup remove' becuase it keeps device open.
---
 test/shell/thin-foreign-repair.sh | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/test/shell/thin-foreign-repair.sh b/test/shell/thin-foreign-repair.sh
index 147a9a073..8b4018e4e 100644
--- a/test/shell/thin-foreign-repair.sh
+++ b/test/shell/thin-foreign-repair.sh
@@ -56,7 +56,9 @@ dmsetup create "$THIN" --table "0 40960 thin $DM_DEV_DIR/mapper/$POOL 0"
 
 mkfs.ext4 "$DM_DEV_DIR/mapper/$THIN"
 
-dmsetup remove "$THIN"
+aux udev_wait
+
+dmsetup remove "$THIN" || { sleep .5 ; dmsetup remove "$THIN" }
 
 lvchange -an $vg/pool
 


