From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 17 Mar 2014 15:07:37 +0000 (UTC)
Subject: master - config: make global/units and global/si_unit_consistency profilable
Message-ID: <20140317150737.CFED5610DD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1ce2cc86cb1a9bba16b62119829e1e1ddc0ff87
Commit:        c1ce2cc86cb1a9bba16b62119829e1e1ddc0ff87
Parent:        a2c544dc91d8712b49c44aeea2241b37044eedac
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 17 16:03:53 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 17 16:07:29 2014 +0100

config: make global/units and global/si_unit_consistency profilable

---
 WHATS_NEW                    |    3 ++-
 conf/default.profile.in      |    5 +++++
 lib/commands/toolcontext.c   |   25 ++++++++++++++++---------
 lib/commands/toolcontext.h   |    1 +
 lib/config/config_settings.h |    6 +++---
 tools/lvmcmdline.c           |    2 ++
 6 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 06b8033..f104a0c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,8 +1,9 @@
 Version 2.02.106 - 
 ====================================
+  Make global/units and global/si_unit_consistency lvm.conf setting profilable.
   Validate minimal chunk size for snapshot COW volume in lvconvert.
   Disallow lvconvert of origin to snapshot COW volume.
-  Make report settings profilable.
+  Make report lvm.conf settings profilable.
   Add existing report settings to lvm.conf.
   Use VG read lock during 'pvscan --cache -aay' autoactivation.
   Issue a VG refresh before autoactivation only if the PV has changed/is new.
diff --git a/conf/default.profile.in b/conf/default.profile.in
index 0499aef..2bf2143 100644
--- a/conf/default.profile.in
+++ b/conf/default.profile.in
@@ -20,6 +20,11 @@ activation {
 	thin_pool_autoextend_percent = 20
 }
 
+global {
+	units="h"
+	si_unit_consistency=1
+}
+
 report {
 	aligned=1
 	buffered=1
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 7282592..c616558 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -279,6 +279,19 @@ static int _check_config(struct cmd_context *cmd)
 	return 1;
 }
 
+int process_profilable_config(struct cmd_context *cmd) {
+	if (!(cmd->default_settings.unit_factor =
+	      units_to_bytes(find_config_tree_str(cmd, global_units_CFG, NULL),
+			     &cmd->default_settings.unit_type))) {
+		log_error("Invalid units specification");
+		return 0;
+	}
+
+	cmd->si_unit_consistency = find_config_tree_bool(cmd, global_si_unit_consistency_CFG, NULL);
+
+	return 1;
+}
+
 static int _process_config(struct cmd_context *cmd)
 {
 	mode_t old_umask;
@@ -339,13 +352,6 @@ static int _process_config(struct cmd_context *cmd)
 
 	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG, NULL);
 
-	if (!(cmd->default_settings.unit_factor =
-	      units_to_bytes(find_config_tree_str(cmd, global_units_CFG, NULL),
-			     &cmd->default_settings.unit_type))) {
-		log_error("Invalid units specification");
-		return 0;
-	}
-
 	read_ahead = find_config_tree_str(cmd, activation_readahead_CFG, NULL);
 	if (!strcasecmp(read_ahead, "auto"))
 		cmd->default_settings.read_ahead = DM_READ_AHEAD_AUTO;
@@ -407,8 +413,6 @@ static int _process_config(struct cmd_context *cmd)
 		}
 	}
 
-	cmd->si_unit_consistency = find_config_tree_bool(cmd, global_si_unit_consistency_CFG, NULL);
-
 	if ((cn = find_config_tree_node(cmd, activation_mlock_filter_CFG, NULL)))
 		for (cv = cn->v; cv; cv = cv->next) 
 			if ((cv->type != DM_CFG_STRING) || !cv->v.str[0]) 
@@ -425,6 +429,9 @@ static int _process_config(struct cmd_context *cmd)
 	/* LVM stores sizes internally in units of 512-byte sectors. */
 	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
 
+	if (!process_profilable_config(cmd))
+		return_0;
+
 	init_detect_internal_vg_cache_corruption
 		(find_config_tree_bool(cmd, global_detect_internal_vg_cache_corruption_CFG, NULL));
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 7a50e1e..0cd9a2f 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -138,6 +138,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int refresh_filters(struct cmd_context *cmd);
+int process_profilable_config(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
 int init_lvmcache_orphans(struct cmd_context *cmd);
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index de6ca1b..77acb45 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -74,7 +74,7 @@ cfg_section(allocation_CFG_SECTION, "allocation", root_CFG_SECTION, CFG_PROFILAB
 cfg_section(log_CFG_SECTION, "log", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
 cfg_section(backup_CFG_SECTION, "backup", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
 cfg_section(shell_CFG_SECTION, "shell", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
-cfg_section(global_CFG_SECTION, "global", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
+cfg_section(global_CFG_SECTION, "global", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), NULL)
 cfg_section(activation_CFG_SECTION, "activation", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), NULL)
 cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, CFG_ADVANCED, vsn(1, 0, 0), NULL)
 cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_ADVANCED | CFG_PROFILABLE, vsn(1, 0, 0), NULL)
@@ -150,8 +150,8 @@ cfg(shell_history_size_CFG, "history_size", shell_CFG_SECTION, 0, CFG_TYPE_INT,
 
 cfg(global_umask_CFG, "umask", global_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_UMASK, vsn(1, 0, 0), NULL)
 cfg(global_test_CFG, "test", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(1, 0, 0), NULL)
-cfg(global_units_CFG, "units", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_UNITS, vsn(1, 0, 0), NULL)
-cfg(global_si_unit_consistency_CFG, "si_unit_consistency", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SI_UNIT_CONSISTENCY,  vsn(2, 2, 54), NULL)
+cfg(global_units_CFG, "units", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_UNITS, vsn(1, 0, 0), NULL)
+cfg(global_si_unit_consistency_CFG, "si_unit_consistency", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SI_UNIT_CONSISTENCY,  vsn(2, 2, 54), NULL)
 cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION, vsn(1, 0, 0), NULL)
 cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SUFFIX, vsn(1, 0, 0), NULL)
 cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18), NULL)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6fe4670..454bee8 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1137,6 +1137,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 			log_error("Failed to apply configuration profile.");
 			return ECMD_FAILED;
 		}
+		if (!process_profilable_config(cmd))
+			return_ECMD_FAILED;
 	}
 
 	if ((ret = _get_settings(cmd)))


