From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 18 Mar 2014 08:27:10 +0000 (UTC)
Subject: master - config: make global/suffix profilable and add it to lvm.conf
Message-ID: <20140318082710.9E355611BF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=927784cd063ebd4aa3a82ad815db9e1811a900c4
Commit:        927784cd063ebd4aa3a82ad815db9e1811a900c4
Parent:        64086c3bd827c3f276886125711b112e87bcfd03
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 18 09:24:17 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 18 09:24:17 2014 +0100

config: make global/suffix profilable and add it to lvm.conf

The global/suffix was missing from example lvm.conf but it can
be very useful when using lvm in scripts and now in profiles as well
Let's expose it more.
---
 conf/default.profile.in      |    1 +
 conf/example.conf.in         |    5 +++++
 lib/commands/toolcontext.c   |    3 +--
 lib/config/config_settings.h |    2 +-
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/conf/default.profile.in b/conf/default.profile.in
index 2bf2143..72396e5 100644
--- a/conf/default.profile.in
+++ b/conf/default.profile.in
@@ -23,6 +23,7 @@ activation {
 global {
 	units="h"
 	si_unit_consistency=1
+	suffix=1
 }
 
 report {
diff --git a/conf/example.conf.in b/conf/example.conf.in
index f54ab8d..2ed3fd6 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -483,6 +483,11 @@ global {
     # temporarily until you update them.
     si_unit_consistency = 1
 
+    # Whether or not to display unit suffix for sizes. This setting has
+    # no effect if the units are in human-readable form (global/units="h")
+    # in which case the suffix is always displayed.
+    suffix = 1
+
     # Whether or not to communicate with the kernel device-mapper.
     # Set to 0 if you want to use the tools to manipulate LVM metadata 
     # without activating any logical volumes.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c616558..e620884 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -288,6 +288,7 @@ int process_profilable_config(struct cmd_context *cmd) {
 	}
 
 	cmd->si_unit_consistency = find_config_tree_bool(cmd, global_si_unit_consistency_CFG, NULL);
+	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG, NULL);
 
 	return 1;
 }
@@ -350,8 +351,6 @@ static int _process_config(struct cmd_context *cmd)
 
 	cmd->auto_set_activation_skip = find_config_tree_bool(cmd, activation_auto_set_activation_skip_CFG, NULL);
 
-	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG, NULL);
-
 	read_ahead = find_config_tree_str(cmd, activation_readahead_CFG, NULL);
 	if (!strcasecmp(read_ahead, "auto"))
 		cmd->default_settings.read_ahead = DM_READ_AHEAD_AUTO;
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 77acb45..72f99d5 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -153,7 +153,7 @@ cfg(global_test_CFG, "test", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(1, 0,
 cfg(global_units_CFG, "units", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_UNITS, vsn(1, 0, 0), NULL)
 cfg(global_si_unit_consistency_CFG, "si_unit_consistency", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SI_UNIT_CONSISTENCY,  vsn(2, 2, 54), NULL)
 cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION, vsn(1, 0, 0), NULL)
-cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SUFFIX, vsn(1, 0, 0), NULL)
+cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SUFFIX, vsn(1, 0, 0), NULL)
 cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18), NULL)
 cfg(global_format_CFG, "format", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_FORMAT, vsn(1, 0, 0), NULL)
 cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)


