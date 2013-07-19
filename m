From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 19 Jul 2013 19:38:25 +0000 (UTC)
Subject: master - cmdline: support ARG_GROUPABLE in merge_synonym
Message-ID: <20130719193825.505C160ECE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ccc29f17b61b60aa4c5b2286ed8b530234435d8a
Commit:        ccc29f17b61b60aa4c5b2286ed8b530234435d8a
Parent:        90a09559ed689cbd62021ef0ff875913d43bc989
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 19 20:37:43 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 19 20:37:43 2013 +0100

cmdline: support ARG_GROUPABLE in merge_synonym

---
 WHATS_NEW          |    1 +
 tools/commands.h   |    2 +-
 tools/lvchange.c   |   14 ++++++++------
 tools/lvmcmdline.c |   42 ++++++++++++++++++++++++++++++------------
 4 files changed, 40 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 83a593e..1cce9c9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Support ARG_GROUPABLE with merge_synonym (for --raidwritemostly).
   Fix segfault when reporting raid_syncaction for older kernels.
   Add LV reporting fields raid_mismatch_count, raid_sync_action, raid_write_behind.
   Add LV reporting fields raid_min_recovery_rate, raid_max_recovery_rate.
diff --git a/tools/commands.h b/tools/commands.h
index 1330c8d..841a6b6 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -96,7 +96,7 @@ xx(lvchange,
    "\t[--[raid]maxrecoveryrate Rate]\n"
    "\t[--[raid]syncaction {check|repair}\n"
    "\t[--[raid]writebehind IOCount]\n"
-   "\t[--[raid]writemostly PhysicalVolume]\n"
+   "\t[--[raid]writemostly PhysicalVolume[:{t|n|y}]]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[--refresh]\n"
    "\t[--resync]\n"
diff --git a/tools/lvchange.c b/tools/lvchange.c
index b3207d0..3b40659 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -702,6 +702,7 @@ static int lvchange_writemostly(struct logical_volume *lv)
 	int s, pv_count, i = 0;
 	char **pv_names;
 	const char *tmp_str;
+	size_t tmp_str_len;
 	struct pv_list *pvl;
 	struct arg_value_group_list *group;
 	struct cmd_context *cmd = lv->vg->cmd;
@@ -743,14 +744,15 @@ static int lvchange_writemostly(struct logical_volume *lv)
 			 * We allocate strlen + 3 to add our own ':{t|n|y}' if
 			 * not present plus the trailing '\0'.
 			 */
-			if (!(pv_names[i] = dm_pool_zalloc(lv->vg->vgmem,
-							   strlen(tmp_str) + 3)))
+			tmp_str_len = strlen(tmp_str);
+			if (!(pv_names[i] = dm_pool_zalloc(lv->vg->vgmem, tmp_str_len + 3)))
 				return_0;
 
-			if ((tmp_str[strlen(tmp_str) - 2] != ':') &&
-			    ((tmp_str[strlen(tmp_str) - 1] != 't') ||
-			     (tmp_str[strlen(tmp_str) - 1] != 'y') ||
-			     (tmp_str[strlen(tmp_str) - 1] != 'n')))
+			if (tmp_str_len < 3 ||
+			    (tmp_str[tmp_str_len - 2] != ':') &&
+			    ((tmp_str[tmp_str_len - 1] != 't') ||
+			     (tmp_str[tmp_str_len - 1] != 'y') ||
+			     (tmp_str[tmp_str_len - 1] != 'n')))
 				/* Default to 'y' if no mode specified */
 				sprintf(pv_names[i], "%s:y", tmp_str);
 			else
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 66c4536..a155d21 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -801,10 +801,24 @@ static int _process_command_line(struct cmd_context *cmd, int *argc,
 	return 1;
 }
 
+static void _copy_arg_values(struct arg_values *av, int oldarg, int newarg)
+{
+	const struct arg_values *old = av + oldarg;
+	struct arg_values *new = av + newarg;
+
+	new->count = old->count;
+	new->value = old->value;
+	new->i_value = old->i_value;
+	new->ui_value = old->ui_value;
+	new->i64_value = old->i64_value;
+	new->ui64_value = old->ui64_value;
+	new->sign = old->sign;
+}
+
 static int _merge_synonym(struct cmd_context *cmd, int oldarg, int newarg)
 {
-	const struct arg_values *old;
-	struct arg_values *new;
+	struct arg_values *av;
+	struct arg_value_group_list *current_group;
 
 	if (arg_count(cmd, oldarg) && arg_count(cmd, newarg)) {
 		log_error("%s and %s are synonyms.  Please only supply one.",
@@ -812,19 +826,23 @@ static int _merge_synonym(struct cmd_context *cmd, int oldarg, int newarg)
 		return 0;
 	}
 
-	if (!arg_count(cmd, oldarg))
+	/* Not groupable? */
+	if (!(_cmdline.arg_props[oldarg].flags & ARG_GROUPABLE)) {
+		if (arg_count(cmd, oldarg))
+			_copy_arg_values(cmd->arg_values, oldarg, newarg);
 		return 1;
+	}
 
-	old = cmd->arg_values + oldarg;
-	new = cmd->arg_values + newarg;
+	if (arg_count(cmd, oldarg))
+		cmd->arg_values[newarg].count = cmd->arg_values[oldarg].count;
 
-	new->count = old->count;
-	new->value = old->value;
-	new->i_value = old->i_value;
-	new->ui_value = old->ui_value;
-	new->i64_value = old->i64_value;
-	new->ui64_value = old->ui64_value;
-	new->sign = old->sign;
+	/* Groupable */
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+		av = current_group->arg_values;
+		if (!grouped_arg_count(av, oldarg))
+			continue;
+		_copy_arg_values(av, oldarg, newarg);
+	}
 
 	return 1;
 }


