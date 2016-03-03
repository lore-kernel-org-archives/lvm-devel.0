From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:03 +0000 (UTC)
Subject: master - report: display (h)istorical state in lv_attr field
Message-ID: <20160303132003.893876024B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b9953e8c59ef4c3ced277cc40b8bb5006a24161
Commit:        8b9953e8c59ef4c3ced277cc40b8bb5006a24161
Parent:        2af59715235dedb0ab9f1768d6bbccfdc5d28d02
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:23:58 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:15 2016 +0100

report: display (h)istorical state in lv_attr field

The 'historical' state is displayed as 5th bit ("state") in the lv_attr
field and denoted by new 'h' character.
---
 lib/metadata/lv.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index ab937c4..9e9549d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1040,7 +1040,7 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 	}
 
 	/* Blank if this is a "free space" LV. */
-	if (!*lv->name)
+	if (!*lv->name && !lv_is_historical(lv))
 		goto out;
 
 	if (lv_is_pvmove(lv))
@@ -1104,7 +1104,10 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 
 	repstr[3] = (lv->status & FIXED_MINOR) ? 'm' : '-';
 
-	if (!activation() || !lvdm->info_ok) {
+	if (lv_is_historical(lv)) {
+		repstr[4] = 'h';
+		repstr[5] = '-';
+	} else if (!activation() || !lvdm->info_ok) {
 		repstr[4] = 'X';		/* Unknown */
 		repstr[5] = 'X';		/* Unknown */
 	} else if (lvdm->info.exists) {


