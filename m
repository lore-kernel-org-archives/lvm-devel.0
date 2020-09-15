From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 Sep 2020 21:21:23 +0000 (GMT)
Subject: master - tests: switch for checking version of installed tools
Message-ID: <20200915212123.1510F3984041@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2c6bd480b28bec43c7c2652938233d8850f00928
Commit:        2c6bd480b28bec43c7c2652938233d8850f00928
Parent:        cf4fed37617c71f6fd3f00f80beafb4737d53ced
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 14 21:25:04 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 15 23:07:06 2020 +0200

tests: switch for checking version of installed tools

It looks like older tools were compacting metadata more.
---
 test/shell/lvextend-thin-metadata-dmeventd.sh | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index ccdf9e853..db4f7c156 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -20,12 +20,6 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 . lib/inittest
 
 
-# With thin-pool version >= 1.19 and kernel >= 4.18
-# slightly less metadata can fit.
-BIG_DATA="generate_more_metadata"
-aux target_at_least dm-thin-pool 1 19 0 && \
-	aux kernel_at_least 4 18 0 && BIG_DATA=""
-
 meta_percent_() {
 	get lv_field $vg/pool metadata_percent | cut -d. -f1
 }
@@ -66,6 +60,12 @@ test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_r
 "$LVM_TEST_THIN_RESTORE_CMD" -V || skip
 aux have_thin 1 10 0 || skip
 
+BIG_DATA=""
+case $("$LVM_TEST_THIN_RESTORE_CMD" -V) in
+	# With older version of thin-tool we got slightly more compact metadata
+	0.[0..6]*) BIG_DATA="generate_more_metadata" ;;
+esac
+
 aux prepare_dmeventd
 
 aux prepare_pvs 3 256


