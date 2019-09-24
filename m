From: David Teigland <teigland@sourceware.org>
Date: Tue, 24 Sep 2019 16:56:01 -0400
Subject: master - lvremove: remove attached cachevol with removed LV
Message-ID: <201909242056.x8OKu1gL015834@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=56aadd7fe2a1d24043ea9d06543c29317ac1cc58
Commit:        56aadd7fe2a1d24043ea9d06543c29317ac1cc58
Parent:        3b36de573ec53a3e616594903ff3ca64ee2dcafa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 24 13:46:40 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 24 15:51:05 2019 -0500

lvremove: remove attached cachevol with removed LV

When an LV is removed that has an attached cachevol,
also remove the cachevol LV.
---
 lib/metadata/lv_manip.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 79e3d15..f404555 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6283,10 +6283,16 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return_0;
 
 	if (lv_is_cache(lv) && lv_is_cache_vol(first_seg(lv)->pool_lv)) {
+		struct logical_volume *cachevol_lv = first_seg(lv)->pool_lv;
+
 		if (!lv_detach_cache_vol(lv, 0)) {
 			log_error("Failed to detach cache from %s", display_lvname(lv));
 			return 0;
 		}
+		if (!lv_remove_single(cmd, cachevol_lv, force, suppress_remove_message)) {
+			log_error("Failed to remove cachevol %s.", display_lvname(cachevol_lv));
+			return 0;
+		}
 	}
 
 	/* FIXME Ensure not referred to by another existing LVs */


