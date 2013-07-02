From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:32:29 +0000 (UTC)
Subject: master - configure: add configure --with-default-profile-subdir
Message-ID: <20130702133229.0E1F160DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f89a8b81cf795d9e658341b4755046b3824acdaa
Commit:        f89a8b81cf795d9e658341b4755046b3824acdaa
Parent:        da3ea66a96e83b69da60af1540492d50f11b055f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:26:40 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:19:08 2013 +0200

configure: add configure --with-default-profile-subdir

Configuration profiles are selected configuration items that can
be loaded dynamically on demand and overlayed over existing
configuration on demand (either on cmd line by selecting the profile
name to be used globally or retrieved from metadata and used per
VG/LV basis only).

The default directory where profiles are stored is configurable
at compile time with --with-default-profile-subdir.
---
 configure               |   19 +++++++++++++++++++
 configure.in            |    8 ++++++++
 lib/misc/configure.h.in |    3 +++
 3 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/configure b/configure
index e8ef786..8a1db74 100755
--- a/configure
+++ b/configure
@@ -671,6 +671,7 @@ DEFAULT_RUN_DIR
 DEFAULT_DM_RUN_DIR
 DEFAULT_LOCK_DIR
 DEFAULT_DATA_ALIGNMENT
+DEFAULT_PROFILE_SUBDIR
 DEFAULT_CACHE_SUBDIR
 DEFAULT_BACKUP_SUBDIR
 DEFAULT_ARCHIVE_SUBDIR
@@ -873,6 +874,7 @@ with_tmpfilesdir
 with_dmeventd_pidfile
 with_dmeventd_path
 with_default_system_dir
+with_default_profile_subdir
 with_default_archive_subdir
 with_default_backup_subdir
 with_default_cache_subdir
@@ -1638,6 +1640,8 @@ Optional Packages:
                           dmeventd path [[EPREFIX/sbin/dmeventd]]
   --with-default-system-dir=DIR
                           default LVM system directory [[/etc/lvm]]
+  --with-default-profile-subdir=SUBDIR
+                          default configuration profile subdir [[profile]]
   --with-default-archive-subdir=SUBDIR
                           default metadata archive subdir [[archive]]
   --with-default-backup-subdir=SUBDIR
@@ -10555,6 +10559,20 @@ _ACEOF
 
 
 
+# Check whether --with-default-profile-subdir was given.
+if test "${with_default_profile_subdir+set}" = set; then :
+  withval=$with_default_profile_subdir; DEFAULT_PROFILE_SUBDIR=$withval
+else
+  DEFAULT_PROFILE_SUBDIR=profile
+fi
+
+
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_PROFILE_SUBDIR "$DEFAULT_PROFILE_SUBDIR"
+_ACEOF
+
+
+
 # Check whether --with-default-archive-subdir was given.
 if test "${with_default_archive_subdir+set}" = set; then :
   withval=$with_default_archive_subdir; DEFAULT_ARCHIVE_SUBDIR=$withval
@@ -10790,6 +10808,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/bl
 k_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index b286358..d90eb1a 100644
--- a/configure.in
+++ b/configure.in
@@ -1421,6 +1421,13 @@ AC_ARG_WITH(default-system-dir,
 AC_DEFINE_UNQUOTED(DEFAULT_SYS_DIR, ["$DEFAULT_SYS_DIR"],
 		   [Path to LVM system directory.])
 
+AC_ARG_WITH(default-profile-subdir,
+	    AC_HELP_STRING([--with-default-profile-subdir=SUBDIR],
+			   [default configuration profile subdir [[profile]]]),
+	    DEFAULT_PROFILE_SUBDIR=$withval, DEFAULT_PROFILE_SUBDIR=profile)
+AC_DEFINE_UNQUOTED(DEFAULT_PROFILE_SUBDIR, ["$DEFAULT_PROFILE_SUBDIR"],
+		   [Name of default configuration profile subdirectory.])
+
 AC_ARG_WITH(default-archive-subdir,
 	    AC_HELP_STRING([--with-default-archive-subdir=SUBDIR],
 			   [default metadata archive subdir [[archive]]]),
@@ -1521,6 +1528,7 @@ AC_SUBST(DEFAULT_SYS_DIR)
 AC_SUBST(DEFAULT_ARCHIVE_SUBDIR)
 AC_SUBST(DEFAULT_BACKUP_SUBDIR)
 AC_SUBST(DEFAULT_CACHE_SUBDIR)
+AC_SUBST(DEFAULT_PROFILE_SUBDIR)
 AC_SUBST(DEFAULT_DATA_ALIGNMENT)
 AC_SUBST(DEFAULT_LOCK_DIR)
 AC_SUBST(DEFAULT_DM_RUN_DIR)
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index fdc5a26..aae4f24 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -53,6 +53,9 @@
 /* Default directory to keep PID files in. */
 #undef DEFAULT_PID_DIR
 
+/* Name of default configuration profile subdirectory. */
+#undef DEFAULT_PROFILE_SUBDIR
+
 /* Default LVM run directory. */
 #undef DEFAULT_RUN_DIR
 


