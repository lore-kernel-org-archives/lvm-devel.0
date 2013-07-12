From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Jul 2013 19:39:08 +0000 (UTC)
Subject: master - conf: add activation/auto_set_activation_skip
Message-ID: <20130712193908.E65EE612BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d1e5113638dbca6a32166bb2d6691b11c37f0d4
Commit:        8d1e5113638dbca6a32166bb2d6691b11c37f0d4
Parent:        283c93a85878cfb67e1c9f0045065dbc0d63bca6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 12 09:27:17 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 12 20:54:17 2013 +0200

conf: add activation/auto_set_activation_skip

The activation/auto_set_activation_skip enables/disables automatic
adding of the ACTIVATION_SKIP LV flag. By default thin snapshots
are flagged to be skipped during activation.

And by default, the auto_set_activation_skip is enabled.
---
 conf/example.conf.in         |    7 +++++++
 lib/commands/toolcontext.c   |    2 ++
 lib/commands/toolcontext.h   |    1 +
 lib/config/config_settings.h |    1 +
 lib/config/defaults.h        |    1 +
 lib/metadata/lv_manip.c      |   11 ++++++-----
 6 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index cb4d3e5..2032a81 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -697,6 +697,13 @@ activation {
     #
     # read_only_volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 
+    # Each LV can have an 'activation skip' flag stored persistently against it.
+    # During activation, this flag is used to decide whether such an LV is skipped.
+    # The 'activation skip' flag can be set during LV creation and by default it
+    # is automatically set for thin snapshot LVs. The 'auto_set_activation_skip'
+    # enables or disables this automatic setting of the flag while LVs are created.
+    # auto_set_activation_skip = 1
+
     # For RAID or 'mirror' segment types, 'raid_region_size' is the
     # size (in kiB) of each:
     # - synchronization operation when initializing
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 2c4a698..b284ce5 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -342,6 +342,8 @@ static int _process_config(struct cmd_context *cmd)
 	cmd->default_settings.activation = find_config_tree_bool(cmd, global_activation_CFG, NULL);
 	set_activation(cmd->default_settings.activation);
 
+	cmd->auto_set_activation_skip = find_config_tree_bool(cmd, activation_auto_set_activation_skip_CFG, NULL);
+
 	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG, NULL);
 
 	if (!(cmd->default_settings.unit_factor =
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 2d90138..cd91605 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -87,6 +87,7 @@ struct cmd_context {
 	unsigned handles_unknown_segments:1;
 	unsigned use_linear_target:1;
 	unsigned partial_activation:1;
+	unsigned auto_set_activation_skip:1;
 	unsigned si_unit_consistency:1;
 	unsigned metadata_read_only:1;
 	unsigned threaded:1;		/* Set if running within a thread e.g. clvmd */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d9112f5..d2a6765 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -185,6 +185,7 @@ cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, 0
 cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL)
 cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL)
 cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_INTERVAL, vsn(2, 2, 63), NULL)
+cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_AUTO_SET_ACTIVATION_SKIP, vsn(2,2,99), NULL)
 
 cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL)
 cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 7ee89ec..a789a9c 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -140,6 +140,7 @@
 #  define DEFAULT_ACTIVATION 0
 #endif
 
+#define DEFAULT_AUTO_SET_ACTIVATION_SKIP 1
 #define DEFAULT_USE_LINEAR_TARGET 1
 #define DEFAULT_STRIPE_FILLER "error"
 #define DEFAULT_RAID_REGION_SIZE   512	/* KB */
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1dc1529..ee65332 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5286,16 +5286,17 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 void lv_set_activation_skip(struct logical_volume *lv, int override_default,
 			    int add_skip)
 {
-	int skip;
+	int skip = 0;
 
 	/* override default behaviour */
 	if (override_default)
 		skip = add_skip;
 	/* default behaviour */
-	else if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
-		skip = 1; /* skip activation for thin snapshots by default */
-	else
-		skip = 0;
+	else if (lv->vg->cmd->auto_set_activation_skip) {
+		 /* skip activation for thin snapshots by default */
+		if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
+			skip = 1;
+	}
 
 	if (skip)
 		lv->status |= LV_ACTIVATION_SKIP;


