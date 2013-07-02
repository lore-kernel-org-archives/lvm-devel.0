From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:33:10 +0000 (UTC)
Subject: master - profile: add default.profile and install it
Message-ID: <20130702133310.F1DB460DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21554ab5fe958b09eed853f3bfefa61c4c130604
Commit:        21554ab5fe958b09eed853f3bfefa61c4c130604
Parent:        6d1ed2254ccfe2a34f1423ea2359cf6a554e8d9e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 28 14:08:04 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:22:11 2013 +0200

profile: add default.profile and install it

The default.profile contains all settings that are customizable
by a profile. This default profile can be copied across to create
new profiles.
---
 conf/Makefile.in        |   13 +++++++++++--
 conf/default.profile.in |   20 ++++++++++++++++++++
 configure               |    3 ++-
 configure.in            |    1 +
 make.tmpl.in            |    1 +
 5 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/conf/Makefile.in b/conf/Makefile.in
index c63e3ce..c148ac2 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -18,14 +18,23 @@ top_builddir = @top_builddir@
 CONFSRC=example.conf
 CONFDEST=lvm.conf
 
+DEFAULT_PROFILE=default.profile
+PROFILES=$(DEFAULT_PROFILE)
+
 include $(top_builddir)/make.tmpl
 
-install_lvm2: $(CONFSRC)
+install_conf: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
 		echo "$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST)"; \
 		$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST); \
 	fi
 
+install_profiles: $(PROFILES)
+	$(INSTALL) -d $(DEFAULT_PROFILE_DIR)
+	$(INSTALL_DATA) $(PROFILES) $(DEFAULT_PROFILE_DIR)/
+
+install_lvm2: install_conf install_profiles
+
 install: install_lvm2
 
-DISTCLEAN_TARGETS += $(CONFSRC)
+DISTCLEAN_TARGETS += $(CONFSRC) $(DEFAULT_PROFILE)
diff --git a/conf/default.profile.in b/conf/default.profile.in
new file mode 100644
index 0000000..6a0b8f1
--- /dev/null
+++ b/conf/default.profile.in
@@ -0,0 +1,20 @@
+# This is a default profile for the LVM2 system.
+# It contains all configuration settings that are customizable by profiles.
+#
+# To create a new profile, select the settings you want to customize
+# and put them in a new file named <profile_name>.profile. Then put this
+# file in a directory as defined by config/profile_dir setting found in
+# @DEFAULT_SYS_DIR@/lvm.conf file.
+#
+# Refer to 'man lvm.conf' for further information about profiles and file layout.
+
+allocation {
+	thin_pool_chunk_size = 64
+	thin_pool_discards = "passdown"
+	thin_pool_zero = 1
+}
+
+activation {
+	thin_pool_autoextend_threshold = 100
+	thin_pool_autoextend_percent = 20
+}
diff --git a/configure b/configure
index aeb2b46..212bd80 100755
--- a/configure
+++ b/configure
@@ -10810,7 +10810,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/
 blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_
 init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11515,6 +11515,7 @@ do
     "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
     "conf/Makefile") CONFIG_FILES="$CONFIG_FILES conf/Makefile" ;;
     "conf/example.conf") CONFIG_FILES="$CONFIG_FILES conf/example.conf" ;;
+    "conf/default.profile") CONFIG_FILES="$CONFIG_FILES conf/default.profile" ;;
     "include/.symlinks") CONFIG_FILES="$CONFIG_FILES include/.symlinks" ;;
     "include/Makefile") CONFIG_FILES="$CONFIG_FILES include/Makefile" ;;
     "lib/Makefile") CONFIG_FILES="$CONFIG_FILES lib/Makefile" ;;
diff --git a/configure.in b/configure.in
index 77a0503..6d417e3 100644
--- a/configure.in
+++ b/configure.in
@@ -1642,6 +1642,7 @@ daemons/dmeventd/plugins/thin/Makefile
 daemons/lvmetad/Makefile
 conf/Makefile
 conf/example.conf
+conf/default.profile
 include/.symlinks
 include/Makefile
 lib/Makefile
diff --git a/make.tmpl.in b/make.tmpl.in
index df7453d..ae62182 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -81,6 +81,7 @@ DEFAULT_SYS_DIR = @DEFAULT_SYS_DIR@
 DEFAULT_ARCHIVE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_ARCHIVE_SUBDIR@
 DEFAULT_BACKUP_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_BACKUP_SUBDIR@
 DEFAULT_CACHE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_CACHE_SUBDIR@
+DEFAULT_PROFILE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_PROFILE_SUBDIR@
 DEFAULT_LOCK_DIR = @DEFAULT_LOCK_DIR@
 DEFAULT_RUN_DIR = @DEFAULT_RUN_DIR@
 


