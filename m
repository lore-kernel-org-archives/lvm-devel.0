From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 26 Oct 2016 15:54:57 +0000 (UTC)
Subject: master - lvconvert: revert to only letting raid4 through to lv_raid_convert()
Message-ID: <20161026155457.3175C61103@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e84f527cd37fa713774e30c63509bfeef8271618
Commit:        e84f527cd37fa713774e30c63509bfeef8271618
Parent:        0468f5da6d2542a2a9c03df2c9e5adf3fed2131d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Oct 26 17:47:48 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Oct 26 17:54:19 2016 +0200

lvconvert: revert to only letting raid4 through to lv_raid_convert()

Commit de78e8eae73c allowed to let any raid layout through
which we want to avoid until further validation cleanups.

Related to rhbz1386184
---
 tools/lvconvert.c |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1fbe1ea..772c268 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1937,7 +1937,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 1;
 		}
 		goto try_new_takeover_or_reshape;
-	} else if (!lp->repair && !lp->replace && !*lp->type_str) {
+	} else if (!lp->repair && !lp->replace && (!*lp->type_str || seg->segtype == lp->segtype)) {
 		log_error("Conversion operation not yet supported.");
 		return 0;
 	}
@@ -2005,18 +2005,28 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return 1;
 	}
 
+
 try_new_takeover_or_reshape:
+
 	/* FIXME This needs changing globally. */
 	if (!arg_is_set(cmd, stripes_long_ARG))
 		lp->stripes = 0;
 
-	if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
-			     lp->region_size, lp->pvh))
-		return_0;
+	/* Only let raid4 through for now. */
+	if (lp->type_str && lp->type_str[0] && lp->segtype != seg->segtype &&
+	    ((seg_is_raid4(seg) && seg_is_striped(lp) && lp->stripes > 1) ||
+	     (seg_is_striped(seg) && seg->area_count > 1 && seg_is_raid4(lp)))) {
+		if (!lv_raid_convert(lv, lp->segtype, lp->yes, lp->force, lp->stripes, lp->stripe_size_supplied, lp->stripe_size,
+				     lp->region_size, lp->pvh))
+			return_0;
 
-	log_print_unless_silent("Logical volume %s successfully converted.",
-				display_lvname(lv));
-	return 1;
+		log_print_unless_silent("Logical volume %s successfully converted.",
+					display_lvname(lv));
+		return 1;
+	}
+
+	log_error("Conversion operation not yet supported.");
+	return 0;
 }
 
 static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volume *cow,


