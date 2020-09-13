From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 13 Sep 2020 22:16:47 +0000 (GMT)
Subject: master - tests: tune usage of smaller metadata
Message-ID: <20200913221647.6519339518AA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c0d11ecc952ff32b3b5746478d9c76de761775e
Commit:        9c0d11ecc952ff32b3b5746478d9c76de761775e
Parent:        1005fd7b067320d03067229912bf4844d1a54836
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 19:06:05 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 00:15:14 2020 +0200

tests: tune usage of smaller metadata

While the previous commit c9b40083fc34b5e2a1bfc7b251b38c0b8737483f
decresed version to 1.19 for using bigger datasets,  it's not
been quite right - so from our bb machine it looks like
bigger metadata consumption started with 1.19 and kernel 4.18
(fc27)
---
 test/shell/lvextend-thin-metadata-dmeventd.sh | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 38a405668..ccdf9e853 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -19,6 +19,13 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
+
+# With thin-pool version >= 1.19 and kernel >= 4.18
+# slightly less metadata can fit.
+BIG_DATA="generate_more_metadata"
+aux target_at_least dm-thin-pool 1 19 0 && \
+	aux kernel_at_least 4 18 0 && BIG_DATA=""
+
 meta_percent_() {
 	get lv_field $vg/pool metadata_percent | cut -d. -f1
 }
@@ -91,7 +98,7 @@ lvchange -an $vg/pool
 # Consume more then (100% - 4MiB) out of 32MiB metadata volume  (>87.5%)
 # (Test for less than 4MiB free space in metadata, which is less than 25%)
 DATA=7200  # Newer version of thin-pool have hidden reserve, so use lower value
-aux target_at_least dm-thin-pool 1 19 0 || DATA=7400
+test -z "$BIG_DATA" || DATA=7400
 fake_metadata_ "$DATA" 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv2"
 # Swap volume with restored fake metadata
@@ -177,7 +184,7 @@ lvchange -an $vg
 
 #
 DATA=300  # Newer version of thin-pool have hidden reserve, so use lower value
-aux target_at_least dm-thin-pool 1 19 0 || DATA=350
+test -z "$BIG_DATA" || DATA=350
 fake_metadata_ $DATA 2 >data
 lvchange -ay $vg/$lv1
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"


