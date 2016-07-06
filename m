From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  6 Jul 2016 21:45:20 +0000 (UTC)
Subject: master - lvconvert: allow converting type mirror to type linear
Message-ID: <20160706214520.E02AD6030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37d1b7b7454332b8223cbbbae6375566af89da5a
Commit:        37d1b7b7454332b8223cbbbae6375566af89da5a
Parent:        4d1c4e1f7339746eacc850f45085ecd75bfd56a1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 6 16:33:25 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 6 16:33:25 2016 -0500

lvconvert: allow converting type mirror to type linear

The code could perform this conversion but ironically
did not recognize the standard command form, only the
the unpreferred "implication-based" command form.

"lvconvert --type linear VG/MirrorLV" would fail, but
"lvconvert --mirrors 0 VG/MirrorLV" would succeed.
---
 tools/lvconvert.c |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9ce6ef5..d0aa733 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1705,6 +1705,7 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 			      struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
+	const char *new_type;
 	uint32_t old_mimage_count;
 	uint32_t old_log_count;
 	uint32_t new_mimage_count;
@@ -1733,6 +1734,16 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		return 0;
 	}
 
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
 	/* Adjust mimage and/or log count */
 	if (!_lvconvert_mirrors_parse_params(cmd, lv, lp,
 					     &old_mimage_count, &old_log_count,
@@ -3615,6 +3626,20 @@ static int _convert_mirror_repair(struct cmd_context *cmd, struct logical_volume
 }
 
 /*
+ * Convert mirror LV to linear LV.
+ * lvconvert --type linear LV
+ *
+ * Alternate syntax:
+ * lvconvert --mirrors 0 LV
+ */
+
+static int _convert_mirror_linear(struct cmd_context *cmd, struct logical_volume *lv,
+			          struct lvconvert_params *lp)
+{
+	return _lvconvert_mirrors(cmd, lv, lp);
+}
+
+/*
  * Convert mirror LV to raid1 LV.
  * lvconvert --type raid1 LV
  *
@@ -4126,6 +4151,9 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_is_set(cmd, repair_ARG))
 		return _convert_mirror_repair(cmd, lv, lp);
 
+	if (new_type && !strcmp(new_type, SEG_TYPE_NAME_LINEAR))
+		return _convert_mirror_linear(cmd, lv, lp);
+
 	if (new_type && new_segtype && segtype_is_raid(new_segtype))
 		return _convert_mirror_raid(cmd, lv, lp);
 
@@ -4152,6 +4180,7 @@ static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 		  "  --splitmirrors\n"
 		  "  --mirrorlog\n"
 		  "  --repair\n"
+		  "  --type linear\n"
 		  "  --type raid*\n");
 	return 0;
 }


