From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 22 Jun 2016 21:12:30 +0000 (UTC)
Subject: master - lvconvert: Fix --stripes handling.
Message-ID: <20160622211230.E6993610F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6513a7a44950ded037e1fb3e974a089b8e5690df
Commit:        6513a7a44950ded037e1fb3e974a089b8e5690df
Parent:        ebd2758dab39bb70fd63d0d77314971f8bc9cbfd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jun 22 22:10:42 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jun 22 22:10:42 2016 +0100

lvconvert: Fix --stripes handling.

Only treat --stripes as meaning --type striped if no other type was
first detected.  If a segtype got selected, don't override it later.
---
 tools/lvconvert.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9c7f9c2..f99291a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -554,10 +554,9 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->replace = 1;
 
 	/* If no other case was identified, then use of --stripes means --type striped */
-	if (!arg_is_set(cmd, type_ARG) && !lp->merge && !lp->splitsnapshot &&
+	if (!arg_is_set(cmd, type_ARG) && !*lp->type_str && !lp->merge && !lp->splitsnapshot &&
 	    !lp->splitcache && !lp->split && !lp->snapshot && !lp->uncache && !lp->cache && !lp->thin &&
-	    !lp->replace && !_mirror_or_raid_type_requested(cmd, lp->type_str) &&
-	    !lp->repair && !lp->mirrorlog && !lp->corelog &&
+	    !lp->replace && !lp->repair && !lp->mirrorlog && !lp->corelog &&
 	    (arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)))
 		lp->type_str = "striped";
 
@@ -750,7 +749,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 			/* changing mirror type? */
 			if (!(lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL)))))
 				return_0;
-		} /* else segtype will default to current type */
+		} 
 	} else if (_raid0_type_requested(cmd, lp->type_str) || _striped_type_requested(cmd, lp->type_str)) { /* striped or raid0 */
 		if (arg_from_list_is_set(cmd, "cannot be used with --type raid0 or --type striped",
 					 chunksize_ARG, corelog_ARG, mirrors_ARG, mirrorlog_ARG, regionsize_ARG, zero_ARG,
@@ -762,7 +761,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 
 		if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
 			return_0;
-	}
+	} /* else segtype will default to current type */
 
 	lp->force = arg_count(cmd, force_ARG);
 	lp->yes = arg_count(cmd, yes_ARG);
@@ -1790,7 +1789,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	struct lv_segment *seg = first_seg(lv);
 	dm_percent_t sync_percent;
 
-	if (!arg_is_set(cmd, type_ARG))
+	if (!lp->segtype)
 		lp->segtype = seg->segtype;
 
 	/* Can only change image count for raid1 and linear */


