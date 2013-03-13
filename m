From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Mar 2013 14:16:14 +0000 (UTC)
Subject: master - thin: assign through structure
Message-ID: <20130313141614.D0528A0D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0191d99906a0ae017b827752232bb7461ccf8f09
Commit:        0191d99906a0ae017b827752232bb7461ccf8f09
Parent:        f572bf987e15429392b5ed4d2f0f01d53a95563b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 8 14:12:56 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 13 15:13:54 2013 +0100

thin: assign through structure

Just simplify code.
---
 tools/lvconvert.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1ab9971..6a64c2b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1900,32 +1900,32 @@ static int _lvconvert_thinpool_external(struct cmd_context *cmd,
 {
 	struct logical_volume *torigin_lv;
 	struct volume_group *vg = pool_lv->vg;
-	struct lvcreate_params lvc = { 0 };
+	struct lvcreate_params lvc = {
+		.activate = CHANGE_AE,
+		.alloc = ALLOC_INHERIT,
+		.lv_name = lp->origin_lv_name,
+		.major = -1,
+		.minor = -1,
+		.permission = LVM_READ,
+		.pool = pool_lv->name,
+		.pvh = &vg->pvs,
+		.read_ahead = DM_READ_AHEAD_AUTO,
+		.stripes = 1,
+		.vg_name = vg->name,
+		.voriginextents = external_lv->le_count,
+		.voriginsize = external_lv->size,
+	};
 
 	dm_list_init(&lvc.tags);
 
 	if (!(lvc.segtype = get_segtype_from_string(cmd, "thin")))
 		return_0;
 
-	lvc.activate = CHANGE_AE;
-	lvc.alloc = ALLOC_INHERIT;
-	lvc.lv_name = lp->origin_lv_name;
-	lvc.major = -1;
-	lvc.minor = -1;
-	lvc.permission = LVM_READ;
-	lvc.pool = pool_lv->name;
-	lvc.pvh = &vg->pvs;
-	lvc.read_ahead = DM_READ_AHEAD_AUTO;
-	lvc.stripes = 1;
-	lvc.vg_name = vg->name;
-	lvc.voriginextents = external_lv->le_count;
-	lvc.voriginsize = external_lv->size;
-
 	/* New thin LV needs to be created (all messages sent to pool) */
 	if (!(torigin_lv = lv_create_single(vg, &lvc)))
 		return_0;
 
-	/* Activate again via -torigin, so this active LV is not needed */
+	/* Deactivate prepared Thin LV */
 	if (!deactivate_lv(cmd, torigin_lv)) {
 		log_error("Aborting. Unable to deactivate new LV. "
 			  "Manual intervention required.");


