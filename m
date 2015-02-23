From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 22:20:54 +0000 (UTC)
Subject: master - config: Rename allow_system_id to extra_system_ids.
Message-ID: <20150223222054.DE49D60EBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fc2928978bb592a6b62a18bbbb0acee10efbfe2
Commit:        2fc2928978bb592a6b62a18bbbb0acee10efbfe2
Parent:        3d406e5a8dfe254f45585759aafa0720a251f0ad
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 22:19:08 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 22:19:08 2015 +0000

config: Rename allow_system_id to extra_system_ids.

Add warnings to the config file templates and briefly document
each value.
Configure lvmlocal.conf and install in /etc/lvm.
---
 conf/Makefile.in             |   13 +++++++-
 conf/example.conf.in         |   41 ++++++++++++++++++++------
 conf/lvmlocal.conf.in        |   63 ++++++++++++++++++++++++++++--------------
 configure                    |    3 +-
 configure.in                 |    1 +
 lib/config/config_settings.h |    2 +-
 lib/metadata/metadata.c      |   12 +++----
 man/lvmsystemid.7.in         |    8 ++--
 test/shell/system_id.sh      |    2 +-
 tools/vgchange.c             |    2 +-
 10 files changed, 99 insertions(+), 48 deletions(-)

diff --git a/conf/Makefile.in b/conf/Makefile.in
index e56b25e..2d48fb9 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -17,24 +17,33 @@ top_builddir = @top_builddir@
 
 CONFSRC=example.conf
 CONFDEST=lvm.conf
+CONFLOCAL=lvmlocal.conf
 
 PROFILE_TEMPLATES=command_profile_template.profile metadata_profile_template.profile
 PROFILES=$(PROFILE_TEMPLATES) $(srcdir)/thin-generic.profile $(srcdir)/thin-performance.profile
 
 include $(top_builddir)/make.tmpl
 
+.PHONY: install_conf install_localconf install_profiles
+
 install_conf: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
 		echo "$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST)"; \
 		$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST); \
 	fi
 
+install_localconf: $(CONFLOCAL)
+	@if [ ! -e $(confdir)/$(CONFLOCAL) ]; then \
+		echo "$(INSTALL_WDATA) -D $< $(confdir)/$(CONFLOCAL)"; \
+		$(INSTALL_WDATA) -D $< $(confdir)/$(CONFLOCAL); \
+	fi
+
 install_profiles: $(PROFILES)
 	$(INSTALL_DIR) $(DESTDIR)$(DEFAULT_PROFILE_DIR)
 	$(INSTALL_DATA) $(PROFILES) $(DESTDIR)$(DEFAULT_PROFILE_DIR)/
 
-install_lvm2: install_conf install_profiles
+install_lvm2: install_conf install_localconf install_profiles
 
 install: install_lvm2
 
-DISTCLEAN_TARGETS += $(CONFSRC) $(PROFILE_TEMPLATES)
+DISTCLEAN_TARGETS += $(CONFSRC) $(CONFLOCAL) $(PROFILE_TEMPLATES)
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 777280e..574842a 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -838,18 +838,39 @@ global {
     #
     # cache_dump_executable = "@CACHE_DUMP_CMD@"
 
-    # Defines the method lvm will use to find the local system_id.
-    # The options are: none, machineid, uname, lvmlocal, or file.
-    # Unset, or set to an empty string is equivalent to "none".
-    # See lvmsystemid(7) for more information.
+    # The method, if any, used to define a local system ID on this host.
+    # By placing the same system ID on a Volume Group you can prevent
+    # other co-operating hosts in a cluster (each with a different
+    # system ID) from accessing the same Volume Group.
     #
-    # system_id_source = ""
-
-    # Specifies the path to a file containing the local system_id.
-    # It is only used when system_id_source = "file".
-    # See lvmsystemid(7) for more information.
+    # Set this to one of: none, machineid, uname, lvmlocal, or file.
+    #
+    # N.B. Do not use this feature without reading 'man lvmsystemid' to
+    # understand the correct ways to use it and its limitations.
+    #
+    # system_id_source = "none"
+    #
+    # Obtain the system ID from the "system_id" setting in the "local"
+    # section of a configuration file such as @DEFAULT_SYS_DIR@/lvmlocal.conf.
+    #
+    # system_id_source = "lvmlocal"
+    #
+    # Set the system ID from the hostname of the system.
+    # System IDs beginning "localhost" are not permitted.
+    #
+    # system_id_source = "uname"
+    #
+    # Use the contents of the file @DEFAULT_SYS_DIR@/machine-id
+    # to set the system ID.
+    # Comments starting with the character # are ignored.
+    #
+    # system_id_source = "machineid"
+    #
+    # Use the contents of an alternative file to set the system ID.
+    # Comments starting with the character # are ignored.
     #
-    # system_id_file = ""
+    # system_id_source = "file"
+    # system_id_file = "/etc/systemid"
 }
 
 activation {
diff --git a/conf/lvmlocal.conf.in b/conf/lvmlocal.conf.in
index b95ab37..48965e4 100644
--- a/conf/lvmlocal.conf.in
+++ b/conf/lvmlocal.conf.in
@@ -1,33 +1,54 @@
-# This is an example local configuration file for the LVM2 system.
-# It contains the default settings that would be used if there was no
-# @DEFAULT_SYS_DIR@/lvmlocal.conf file.
+# This is a local configuration file template for the LVM2 system
+# which should be installed as @DEFAULT_SYS_DIR@/lvmlocal.conf .
 #
-# Refer to 'man lvm.conf' for further information including the file layout.
+# This file allows you to assign a unique identity to a host running
+# LVM2 that is permitted to access storage devices visible to more than
+# one machine simultaneously.  
 #
-# To put this file in a different directory and override @DEFAULT_SYS_DIR@ set
-# the environment variable LVM_SYSTEM_DIR before running the tools.
+# You must ensure that every such host uses a different system_id
+# identifier, otherwise LVM2 cannot protect you from simultaneous
+# access from multiple hosts and possible data corruption.
 #
-# N.B. Take care that each setting only appears once if uncommenting
-# example settings in this file.
+# Refer to 'man lvmsystemid' for information about the correct ways
+# to use this and its limitations.
 #
-# The lvmlocal.conf file should contain only the "local { }" section
-# which contains settings that should not be shared or repeated among
-# different hosts.
+# Refer to 'man lvm.conf' for information about the file layout.
 #
-# This file should not be copied among hosts.
+# To put this file in a different directory and override
+# @DEFAULT_SYS_DIR@ set the environment variable LVM_SYSTEM_DIR before
+# running the tools.
+#
+# The lvmlocal.conf file is normally expected to contain only the
+# "local" section which contains settings that should not be shared or
+# repeated among different hosts.  (But if other sections are present,
+# they *will* get processed.  Settings in this file override equivalent
+# ones in lvm.conf and are in turn overridden by ones in any enabled
+# lvm_<tag>.conf files.)
+#
+# Please take care that each setting only appears once if uncommenting
+# example settings in this file and never copy this file between
+# hosts to avoid accidentally assigning the same system ID to
+# more than one host!
 
 local {
-    # This defines the system_id of the local host.  It is
-    # only used if lvm.conf system_id_source = "lvmlocal".
-    # When used, it should be set to a unique value.
-    # See lvmsystemid(7) for more information.
+    # This defines the system ID of the local host.  This is used
+    # when global/system_id_source is set to "lvmlocal" in the main
+    # configuration file, conventionally @DEFAULT_SYS_DIR@/lvm.conf.  
+    # When used, it must be set to a unique value - often a hostname -
+    # across all the hosts sharing access to the storage.
     #
+    # By default, no system_id is set.
     # system_id = ""
+    #
+    # Set the system_id to the string "host1".
+    # system_id = "host1"
 
-    # This defines system_id's other than the local system_id
-    # that the local host is allowed to access.
-    # See lvmsystemid(7) for more information.
+    # This defines a list of extra system_ids other than the local
+    # system_id that the local host is allowed to access.  These are
+    # used for all values of global/system_id_source except "none".
     #
-    # allow_system_id = []
+    # Only use this if you have read 'man lvmsystemid' and you are sure
+    # you understand why you need to use it!
+    #
+    # extra_system_ids = []
 }
-
diff --git a/configure b/configure
index 935702a..c5c3b85 100755
--- a/configure
+++ b/configure
@@ -13069,7 +13069,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile
  python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/M
 akefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -13780,6 +13780,7 @@ do
     "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
     "conf/Makefile") CONFIG_FILES="$CONFIG_FILES conf/Makefile" ;;
     "conf/example.conf") CONFIG_FILES="$CONFIG_FILES conf/example.conf" ;;
+    "conf/lvmlocal.conf") CONFIG_FILES="$CONFIG_FILES conf/lvmlocal.conf" ;;
     "conf/command_profile_template.profile") CONFIG_FILES="$CONFIG_FILES conf/command_profile_template.profile" ;;
     "conf/metadata_profile_template.profile") CONFIG_FILES="$CONFIG_FILES conf/metadata_profile_template.profile" ;;
     "include/.symlinks") CONFIG_FILES="$CONFIG_FILES include/.symlinks" ;;
diff --git a/configure.in b/configure.in
index 7c855bf..15d371b 100644
--- a/configure.in
+++ b/configure.in
@@ -1822,6 +1822,7 @@ daemons/dmeventd/plugins/thin/Makefile
 daemons/lvmetad/Makefile
 conf/Makefile
 conf/example.conf
+conf/lvmlocal.conf
 conf/command_profile_template.profile
 conf/metadata_profile_template.profile
 include/.symlinks
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index fe4218e..4083785 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -282,6 +282,6 @@ cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG
 cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
 
 cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
-cfg_array(local_allow_system_id_CFG, "allow_system_id", local_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
 
 cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5acb2b4..c04b67c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4344,21 +4344,18 @@ static int allow_system_id(struct cmd_context *cmd, const char *system_id)
 	const struct dm_config_value *cv;
 	const char *str;
 
-	if (!(cn = find_config_tree_node(cmd, local_allow_system_id_CFG, NULL)))
+	if (!(cn = find_config_tree_node(cmd, local_extra_system_ids_CFG, NULL)))
 		return 0;
 
 	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type == DM_CFG_EMPTY_ARRAY)
 			break;
-		if (cv->type != DM_CFG_STRING) {
-			log_error("Ignoring invalid string in allow_system_id list");
+		/* Ignore invalid data: Warning message already issued by config.c */
+		if (cv->type != DM_CFG_STRING)
 			continue;
-		}
 		str = cv->v.str;
-		if (!*str) {
-			log_error("Ignoring empty string in config file");
+		if (!*str)
 			continue;
-		}
 
 		if (!strcmp(str, system_id))
 			return 1;
@@ -4376,6 +4373,7 @@ static int _access_vg_clustered(struct cmd_context *cmd, struct volume_group *vg
 			log_verbose("Skipping clustered volume group %s", vg->name);
 		return 0;
 	}
+
 	return 1;
 }
 
diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
index c0dd78b..741aafe 100644
--- a/man/lvmsystemid.7.in
+++ b/man/lvmsystemid.7.in
@@ -197,24 +197,24 @@ global {
 
 Changing system_id_source will often cause the system_id to change, which
 may prevent the host from using VGs that it previously used (see
-allow_system_id below to handle this.)
+extra_system_ids below to handle this.)
 
 If a system_id_source other than none fails to resolve a system_id, the
 host will be allowed to access VGs with no system_id, but will not be
 allowed to access VGs with a defined system_id.
 
-.SS allow_system_id
+.SS extra_system_ids
 
 In some cases, it may be useful for a host to access VGs with different
 system_id's, e.g. if a host's system_id changes, and it wants to use VGs
 that it created with its old system_id.  To allow a host to access VGs
 with other system_id's, those other system_id's can be listed in
-lvmlocal.conf local/allow_system_id.
+lvmlocal.conf local/extra_system_ids.
 
 .I lvmlocal.conf
 .nf
 local {
-    allow_system_id = [ "my_other_name" ]
+    extra_system_ids = [ "my_other_name" ]
 }
 .fi
 
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 98924b0..3312ab6 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -386,7 +386,7 @@ rm -f $SIDFILE
 # lvs --foreign: lvs in a foreign vg are reported
 # TODO
 
-# use allow_system_id to read a foreign VG
+# use extra_system_ids to read a foreign VG
 # TODO
 
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index d56b3df..19aeee7 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -480,7 +480,7 @@ static int _vgchange_profile(struct cmd_context *cmd,
  * This function will not be called unless the local host is allowed to use the
  * VG.  Either the VG has no system_id, or the VG and host have matching
  * system_ids, or the host has the VG's current system_id in its
- * allow_system_id list.  This function is not allowed to change the system_id
+ * extra_system_ids list.  This function is not allowed to change the system_id
  * of a foreign VG (VG owned by another host).
  */
 


