From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:57:17 +0000 (UTC)
Subject: master - lvresize: fix pvh handling
Message-ID: <20130611125717.AD87A60E5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ff8b6d7548b218f678c45f768b8383038db1855
Commit:        6ff8b6d7548b218f678c45f768b8383038db1855
Parent:        861fd1108f4873f549c1e1b852243edcf03493d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 11 14:55:32 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 14:55:32 2013 +0200

lvresize: fix pvh handling

Fix bug in previous patch - if only PVs are specified -
it's like if user would have specified size.
---
 tools/lvresize.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index bb9a535..3e2c281 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -458,7 +458,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	uint32_t size_rest;
 	uint32_t pv_extent_count;
 	alloc_policy_t alloc;
-	struct logical_volume *lock_lv;
+	struct logical_volume *lock_lv = NULL;
 	struct lv_list *lvl;
 	struct lv_segment *seg, *uninitialized_var(mirr_seg);
 	uint32_t seg_extents;
@@ -575,7 +575,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	if (lp->sizeargs) { /* TODO: reindent or move to function */
+	if (lp->sizeargs || (pvh != &vg->pvs)) { /* TODO: reindent or move to function */
 
 	switch(lp->percent) {
 		case PERCENT_VG:


