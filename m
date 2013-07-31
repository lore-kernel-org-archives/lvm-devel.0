From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 31 Jul 2013 13:36:30 +0000 (UTC)
Subject: master - thin: metadata resize needs 1.9 version
Message-ID: <20130731133630.E607560319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea605d1ec72960cf8076fb0260dd151a32750ff6
Commit:        ea605d1ec72960cf8076fb0260dd151a32750ff6
Parent:        7b58f104427911c4ef9a82a7726ccc62978e1cf5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 25 14:35:08 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 31 15:29:27 2013 +0200

thin: metadata resize needs 1.9 version

Version 1.8 is not yet fully usable for metadata resize.
---
 WHATS_NEW                            |    1 +
 lib/thin/thin.c                      |    2 +-
 test/shell/lvresize-thin-metadata.sh |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 21c1f6d..71228c9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Require 1.9 thin pool target version for online thin pool metadata resize.
   Ignore previous LV seg with alloc contiguous & cling when num stripes varies.
   Fix segfault if devices/global_filter is not specified correctly.
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 863f051..d559219 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -584,7 +584,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 		{ 1, 1, THIN_FEATURE_EXTERNAL_ORIGIN, "external_origin" },
 		{ 1, 4, THIN_FEATURE_BLOCK_SIZE, "block_size" },
 		{ 1, 5, THIN_FEATURE_DISCARDS_NON_POWER_2, "discards_non_power_2" },
-		{ 1, 8, THIN_FEATURE_METADATA_RESIZE, "metadata_resize" },
+		{ 1, 9, THIN_FEATURE_METADATA_RESIZE, "metadata_resize" },
 	};
 
 	static const char _lvmconf[] = "global/thin_disabled_features";
diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
index d488a43..521b76c 100644
--- a/test/shell/lvresize-thin-metadata.sh
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux have_thin 1 8 0 || skip
+aux have_thin 1 9 0 || skip
 
 aux prepare_pvs 3
 


