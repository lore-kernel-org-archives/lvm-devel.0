From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 15 Jul 2016 21:02:53 +0000 (UTC)
Subject: master - Revert "lvcreate: raid0 needs default number of stripes"
Message-ID: <20160715210253.1E40A60F8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c425cdd115d56a0f0ec7779934f194af88487905
Commit:        c425cdd115d56a0f0ec7779934f194af88487905
Parent:        081e569e14cbf3f3c73aedf0e107b8b3a2c69455
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 15 21:53:37 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 15 21:53:37 2016 +0100

Revert "lvcreate: raid0 needs default number of stripes"

This reverts commit 3928c96a37941d765bf467d82502cd2aec7fd809.

A new setting is required in lvm.conf to control this.
---
 tools/lvcreate.c |   64 +++++++++++++++++++++++++++---------------------------
 1 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 6eca8f2..0dd9b1e 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -458,28 +458,16 @@ static int _read_mirror_params(struct cmd_context *cmd,
 static int _read_raid_params(struct cmd_context *cmd,
 			     struct lvcreate_params *lp)
 {
-	if (lp->stripes < 2) {
-		if (segtype_is_raid10(lp->segtype)) {
-			if (arg_is_set(cmd, stripes_ARG)) {
-				/* User supplied the bad argument */
-				log_error("Segment type 'raid10' requires 2 or more stripes.");
-				return 0;
-			}
-			/* No stripe argument was given - default to 2 */
-			/* FIXME: this needs to change to 3 once we support odd numbers of stripes */
-			lp->stripes = 2;
-		} else if (segtype_is_any_raid6(lp->segtype))
-			lp->stripes = 3;
-		else if (segtype_is_raid4(lp->segtype) ||
-			 segtype_is_any_raid5(lp->segtype) ||
-			 segtype_is_any_raid0(lp->segtype))
-			lp->stripes = 2;
-		else
-			lp->stripes = 1;
-	}
-
-	if (lp->stripes > 1)
+	if ((lp->stripes < 2) && segtype_is_raid10(lp->segtype)) {
+		if (arg_is_set(cmd, stripes_ARG)) {
+			/* User supplied the bad argument */
+			log_error("Segment type 'raid10' requires 2 or more stripes.");
+			return 0;
+		}
+		/* No stripe argument was given - default to 2 */
+		lp->stripes = 2;
 		lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
+	}
 
 	/*
 	 * RAID1 does not take a stripe arg
@@ -1231,31 +1219,43 @@ static int _check_raid_parameters(struct volume_group *vg,
 				  struct lvcreate_params *lp,
 				  struct lvcreate_cmdline_params *lcp)
 {
+	unsigned devs = lcp->pv_count ? : dm_list_size(&vg->pvs);
 	struct cmd_context *cmd = vg->cmd;
 
 	if (!seg_is_mirrored(lp) && !lp->stripe_size)
 		lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
 
-	if (segtype_is_any_raid0(lp->segtype) ||
-	    segtype_is_raid4(lp->segtype) ||
-	    segtype_is_any_raid5(lp->segtype)) {
+	if (seg_is_any_raid0(lp)) {
 		if (lp->stripes < 2) {
-			log_error("Segment type \'%s\' requires 2 or more stripes.", lp->segtype->name);
+			log_error("Segment type 'raid0' requires 2 or more stripes.");
 			return 0;
 		}
-	} else if (segtype_is_any_raid6(lp->segtype)) {
-		if (lp->stripes < 3) {
-			log_error("Segment type \'%s\' requires 3 or more stripes.", lp->segtype->name);
+	} else if (!seg_is_mirrored(lp)) {
+		/*
+		 * If number of devices was not supplied, we can infer from
+		 * the PVs given.
+		 */
+		if (!arg_is_set(cmd, stripes_ARG) &&
+		    (devs > 2 * lp->segtype->parity_devs))
+			lp->stripes = devs - lp->segtype->parity_devs;
+
+		if (lp->stripes <= lp->segtype->parity_devs) {
+			log_error("Number of stripes must be at least %d for %s",
+				  lp->segtype->parity_devs + 1,
+				  lp->segtype->name);
 			return 0;
 		}
-	} else if (segtype_is_raid10(lp->segtype)) {
+	} else if (segtype_is_any_raid0(lp->segtype) ||
+		   segtype_is_raid10(lp->segtype)) {
+		if (!arg_is_set(cmd, stripes_ARG))
+			lp->stripes = devs / lp->mirrors;
 		if (lp->stripes < 2) {
-			log_error("Unable to create %s LV: "
-				  "insufficient number of devices.", lp->segtype->name);
+			log_error("Unable to create RAID(1)0 LV: "
+				  "insufficient number of devices.");
 			return 0;
 		}
 	}
-	/* 'mirrors' defaults to 2 */
+	/* 'mirrors' defaults to 2 - not the number of PVs supplied */
 
 	return 1;
 }


