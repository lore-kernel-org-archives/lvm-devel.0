From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 23 Apr 2014 12:35:21 +0000 (UTC)
Subject: master - man: minor fixes in lvmetad man page
Message-ID: <20140423123521.24A1F60D7B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b09def6068e69a920972211572235a827e7c474
Commit:        2b09def6068e69a920972211572235a827e7c474
Parent:        795944f178c233ac3f638574de704322f130078a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 23 14:31:42 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 23 14:34:42 2014 +0200

man: minor fixes in lvmetad man page

 - better add reference to lvm dumpconfig --type default
   than stating that lvmetad is not enabled by default
 - substitute #DEFAULT_PID_DIR# with concrete value
---
 aclocal.m4       |   15 +++++++++++++++
 configure        |    2 ++
 configure.in     |    1 +
 man/Makefile.in  |    2 +-
 man/lvmetad.8.in |    5 ++++-
 5 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index c9f8f52..6f752f2 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -212,4 +212,19 @@ m4_popdef([pkg_default])
 m4_popdef([pkg_description])
 ]) dnl PKG_NOARCH_INSTALLDIR
 
+
+# PKG_CHECK_VAR(VARIABLE, MODULE, CONFIG-VARIABLE,
+# [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
+# -------------------------------------------
+# Retrieves the value of the pkg-config variable for the given module.
+AC_DEFUN([PKG_CHECK_VAR],
+[AC_REQUIRE([PKG_PROG_PKG_CONFIG])dnl
+AC_ARG_VAR([$1], [value of $3 for $2, overriding pkg-config])dnl
+
+_PKG_CONFIG([$1], [variable="][$3]["], [$2])
+AS_VAR_COPY([$1], [pkg_cv_][$1])
+
+AS_VAR_IF([$1], [""], [$5], [$4])dnl
+])# PKG_CHECK_VAR
+
 m4_include([acinclude.m4])
diff --git a/configure b/configure
index 2032e15..bc8abd9 100755
--- a/configure
+++ b/configure
@@ -697,6 +697,7 @@ DMEVENTD
 DL_LIBS
 DEVMAPPER
 DEFAULT_RUN_DIR
+DEFAULT_PID_DIR
 DEFAULT_DM_RUN_DIR
 DEFAULT_LOCK_DIR
 DEFAULT_DATA_ALIGNMENT
@@ -11539,6 +11540,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile conf/Makefile conf/example.conf conf/default.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.s
 h scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/lvm2_clvmd_systemd_red_hat.service scripts/cmirrord_init_red_hat scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index f3c3570..3a6dc15 100644
--- a/configure.in
+++ b/configure.in
@@ -1674,6 +1674,7 @@ AC_SUBST(DEFAULT_PROFILE_SUBDIR)
 AC_SUBST(DEFAULT_DATA_ALIGNMENT)
 AC_SUBST(DEFAULT_LOCK_DIR)
 AC_SUBST(DEFAULT_DM_RUN_DIR)
+AC_SUBST(DEFAULT_PID_DIR)
 AC_SUBST(DEFAULT_RUN_DIR)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
diff --git a/man/Makefile.in b/man/Makefile.in
index 6c59c8e..af108cf 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -96,7 +96,7 @@ $(MAN5) $(MAN7) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
 %: %.in
 	@case "$@" in \
 	  */*) ;; \
-	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+;" $< > $@ ;; \
+	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;s+#DEFAULT_PID_DIR#+ at DEFAULT_PID_DIR@+;s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+;" $< > $@ ;; \
 	esac
 
 install_man5: $(MAN5)
diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index 444c7c0..a8ca678 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -19,7 +19,10 @@ from udev rules (which must be installed for LVM to work correctly when lvmetad
 is in use). Through these notifications, lvmetad has an up-to-date and
 consistent image of the volume groups available in the system.
 
-By default, lvmetad, even if running, is not used by LVM. See \fBlvm.conf\fP(5).
+lvmetad is used by LVM only if it is enabled in \fBlvm.conf\fP(5) by specifying the
+\fBglobal/use_lvmetad\fP setting. If this is not defined in the LVM configuration
+explicitly then default setting is used instead (see the output of
+\fBlvm dumpconfig --type default global/use_lvmetad\fP command).
 .SH OPTIONS
 
 To run the daemon in a test environment both the pidfile_path and the


