From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Dec 2013 10:18:57 +0000 (UTC)
Subject: master - thin: thin metadata resize unsupported with 1.9
Message-ID: <20131210101857.802DE601DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e3b7fa4b8d310ffc14ed10039caf43e1a9140f64
Commit:        e3b7fa4b8d310ffc14ed10039caf43e1a9140f64
Parent:        99d5b4b807f95ac1845526dc23553ef6442f883e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 10 11:10:53 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 11:17:37 2013 +0100

thin: thin metadata resize unsupported with 1.9

Thin kernel target 1.9 still does not support online resize of
thin pool metadata properly - so disable it with expectation
for much higher version - and reenable after fixing kernel.
---
 WHATS_NEW                            |    1 +
 lib/thin/thin.c                      |    2 +-
 test/shell/lvresize-thin-metadata.sh |    7 +++++--
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 44b545a..7068289 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Disable online thin pool metadata resize for 1.9 kernel thin target.
   Shortened code for initialization of raid segment types.
   Cache global library dir in command context.
   Return success when inserting dirs and links into device cache.
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 5f0c271..df6482e 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -624,7 +624,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 		{ 1, 1, THIN_FEATURE_EXTERNAL_ORIGIN, "external_origin" },
 		{ 1, 4, THIN_FEATURE_BLOCK_SIZE, "block_size" },
 		{ 1, 5, THIN_FEATURE_DISCARDS_NON_POWER_2, "discards_non_power_2" },
-		{ 1, 9, THIN_FEATURE_METADATA_RESIZE, "metadata_resize" },
+		{ 9, 9, THIN_FEATURE_METADATA_RESIZE, "metadata_resize" },
 	};
 
 	static const char _lvmconf[] = "global/thin_disabled_features";
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index 521b76c..16a7500 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -11,9 +11,9 @@
 
 . lib/test
 
-aux have_thin 1 9 0 || skip
+aux have_thin 9 9 0 || skip
 
-aux prepare_pvs 3
+aux prepare_pvs 3 256
 
 vgcreate -s 1M $vg $(cat DEVICES)
 
@@ -31,7 +31,10 @@ for deactivate in true false; do
 	check lv_field $vg/pool_tmeta size "4.00m"
 
 # TODO: Add more tests when kernel is fixed
+	lvresize --alloc anywhere --poolmetadata +256 $vg/pool
 
+	vgchange -an $vg
+	vgchange -ay $vg
 
 # TODO: Make a full metadata device and test dmeventd support
 	lvremove -ff $vg


