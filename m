From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  6 Jul 2016 21:45:23 +0000 (UTC)
Subject: master - lvconvert: allow converting type raid1 to type linear
Message-ID: <20160706214523.016EE6030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13cd3ff5a0dd1652cf20697dbb0d768c6b5115f1
Commit:        13cd3ff5a0dd1652cf20697dbb0d768c6b5115f1
Parent:        37d1b7b7454332b8223cbbbae6375566af89da5a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 6 16:44:18 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 6 16:44:18 2016 -0500

lvconvert: allow converting type raid1 to type linear

The code could perform this conversion but ironically
did not recognize the standard command form, only the
the unpreferred "implication-based" command form.

"lvconvert --type linear VG/RaidLV" would fail, but
"lvconvert --mirrors 0 VG/RaidLV" would succeed.
---
 tools/lvconvert.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d0aa733..ce858ae 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1823,6 +1823,7 @@ static void _lvconvert_raid_repair_ask(struct cmd_context *cmd,
 
 static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
 {
+	const char *new_type;
 	int replace = 0, image_count = 0;
 	struct dm_list *failed_pvs;
 	struct cmd_context *cmd = lv->vg->cmd;
@@ -1832,6 +1833,16 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (!lp->segtype)
 		lp->segtype = seg->segtype;
 
+	if ((new_type = arg_str_value(cmd, type_ARG, NULL)) &&
+	    !strcmp(new_type, SEG_TYPE_NAME_LINEAR)) {
+		if (arg_is_set(cmd, mirrors_ARG) && (arg_uint_value(cmd, mirrors_ARG, 0) != 0)) {
+			log_error("Cannot specify mirrors with linear type.");
+			return 0;
+		}
+		lp->mirrors_supplied = 1;
+		lp->mirrors = 0;
+	}
+
 	/* Can only change image count for raid1 and linear */
 	if (lp->mirrors_supplied && !seg_is_mirrored(seg) && !seg_is_linear(seg)) {
 		log_error("'--mirrors/-m' is not compatible with %s",


