From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 30 Nov 2016 21:58:29 +0000 (UTC)
Subject: master - lvchange: allow a transiently failed RaidLV to be refreshed
Message-ID: <20161130215829.E6D9660F91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b8bf73a63d8dbd9fa32a32c7d47a277d4fb8eb1
Commit:        0b8bf73a63d8dbd9fa32a32c7d47a277d4fb8eb1
Parent:        58f4d98af11eaf21df00aaaf987ca6a92039db7f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Nov 30 22:56:37 2016 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Nov 30 22:57:54 2016 +0100

lvchange: allow a transiently failed RaidLV to be refreshed

In case any SubLV of a RaidLV transiently fails, it needs
two "lvchange --refresh RaidLV" runs to get it to fully
operational mode again.  Reason being, that lvm reloads all
targets for the RaidLV tree but doesn't resume the SubLVs
until after the whole tree has been reloaded in the first
refresh run.  Thus the live mapping table of the SubLVs
still point to an "error" mapping and the dm-raid target
can't retrieve any superblock from the MetaLV(s) in processing
the constructor during this preload thus not discovering the
again accessible SubLVs.  In the second run, the SubLV targets
map proper (meta)data, hence the constructor discovers those
fine now.

Solve by resuming the SubLVs of the RaidLV before
preloading the respective top-level RaidLV target.

Resolves: rhbz1399844
---
 lib/metadata/lv_manip.c |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 10c0446..120217f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1382,7 +1382,7 @@ int replace_lv_with_error_segment(struct logical_volume *lv)
 	return 1;
 }
 
-int lv_refresh_suspend_resume(const struct logical_volume *lv)
+static int _lv_refresh_suspend_resume(const struct logical_volume *lv)
 {
 	struct cmd_context *cmd = lv->vg->cmd;
 	int r = 1;
@@ -1407,6 +1407,33 @@ int lv_refresh_suspend_resume(const struct logical_volume *lv)
 	return r;
 }
 
+int lv_refresh_suspend_resume(const struct logical_volume *lv)
+{
+	/*
+	 * FIXME:
+	 *
+	 * in case of RAID, refresh the SubLVs before
+	 * refreshing the top-level one in order to cope
+	 * with transient failures of SubLVs.
+	 */
+	if (lv_is_raid(lv)) {
+		uint32_t s;
+		struct lv_segment *seg = first_seg(lv);
+
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) == AREA_LV &&
+			    !_lv_refresh_suspend_resume(seg_lv(seg, s)))
+				return 0;
+			if (seg->meta_areas &&
+			    seg_metatype(seg, s) == AREA_LV &&
+			    !_lv_refresh_suspend_resume(seg_metalv(seg, s)))
+				return 0;
+		}
+	}
+
+	return _lv_refresh_suspend_resume(lv);
+}
+
 /*
  * Remove given number of extents from LV.
  */


