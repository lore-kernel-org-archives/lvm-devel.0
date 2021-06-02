From: David Teigland <teigland@sourceware.org>
Date: Wed,  2 Jun 2021 16:14:04 +0000 (GMT)
Subject: main - writecache: don't pvmove device used by writecache
Message-ID: <20210602161404.66D4C3955408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7f107c24666c8577f30e530b74f1ce0347e459b
Commit:        e7f107c24666c8577f30e530b74f1ce0347e459b
Parent:        247f69f9aafe731ef85268da1e6ce817295b265d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 2 11:12:20 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 2 11:12:20 2021 -0500

writecache: don't pvmove device used by writecache

The existing check didn't cover the unusual case where the
cachevol exists on the same device as the origin LV.
---
 tools/pvmove.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index da635a662..bb372f7dc 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -387,6 +387,15 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			return NULL;
 		}
 
+		if (lv_is_writecache(lv)) {
+			struct logical_volume *lv_cachevol = first_seg(lv)->writecache;
+			if (lv_is_on_pvs(lv_cachevol, source_pvl)) {
+				log_error("Unable to move device used for writecache cachevol %s.", display_lvname(lv_cachevol));
+				return NULL;
+			}
+
+		}
+
 		if (lv_is_raid(lv) && lv_raid_has_integrity(lv)) {
 			log_error("Unable to pvmove device used for raid with integrity.");
 			return NULL;


