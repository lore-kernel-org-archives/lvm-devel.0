From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 18 Aug 2015 14:26:09 +0000 (UTC)
Subject: master - configure: check for -lm and log10 function
Message-ID: <20150818142609.2E3E161120@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1bd76d6fcbbc7c07c99a5738dea99f830f79810
Commit:        c1bd76d6fcbbc7c07c99a5738dea99f830f79810
Parent:        a7abade088b5085eed248ab4369fa70263a40bfc
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Aug 18 15:21:19 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Aug 18 15:25:54 2015 +0100

configure: check for -lm and log10 function

We already use -lm functions in a couple of places (these are
satisfied by gcc built-ins for most builds): add a configure.in
check and explicitly link to -lm.
---
 configure         |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 configure.in      |    5 +++++
 libdm/Makefile.in |    2 +-
 make.tmpl.in      |    1 +
 4 files changed, 53 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index 630f12a..57bec69 100755
--- a/configure
+++ b/configure
@@ -665,6 +665,7 @@ PYTHON_LIBDIRS
 PYTHON_INCDIRS
 PYTHON_BINDINGS
 PTHREAD_LIBS
+M_LIBS
 POOL
 PKGCONFIG
 OCFDIR
@@ -12570,6 +12571,50 @@ if [ \( "$LVM1" = shared -o "$POOL" = shared -o "$CLUSTER" = shared \
 fi
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for log10 in -lm" >&5
+$as_echo_n "checking for log10 in -lm... " >&6; }
+if ${ac_cv_lib_m_log10+:} false; then :
+  $as_echo_n "(cached) " >&6
+else
+  ac_check_lib_save_LIBS=$LIBS
+LIBS="-lm  $LIBS"
+cat confdefs.h - <<_ACEOF >conftest.$ac_ext
+/* end confdefs.h.  */
+
+/* Override any GCC internal prototype to avoid an error.
+   Use char because int might match the return type of a GCC
+   builtin and then its argument prototype would still apply.  */
+#ifdef __cplusplus
+extern "C"
+#endif
+char log10 ();
+int
+main ()
+{
+return log10 ();
+  ;
+  return 0;
+}
+_ACEOF
+if ac_fn_c_try_link "$LINENO"; then :
+  ac_cv_lib_m_log10=yes
+else
+  ac_cv_lib_m_log10=no
+fi
+rm -f core conftest.err conftest.$ac_objext \
+    conftest$ac_exeext conftest.$ac_ext
+LIBS=$ac_check_lib_save_LIBS
+fi
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_m_log10" >&5
+$as_echo "$ac_cv_lib_m_log10" >&6; }
+if test "x$ac_cv_lib_m_log10" = xyes; then :
+  M_LIBS="-lm"
+else
+  hard_bailout
+fi
+
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for pthread_mutex_lock in -lpthread" >&5
 $as_echo_n "checking for pthread_mutex_lock in -lpthread... " >&6; }
 if ${ac_cv_lib_pthread_pthread_mutex_lock+:} false; then :
@@ -14153,6 +14198,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdev
 mapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan
 _systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index c3e55e9..2c89d8c 100644
--- a/configure.in
+++ b/configure.in
@@ -1538,6 +1538,10 @@ if [[ \( "$LVM1" = shared -o "$POOL" = shared -o "$CLUSTER" = shared \
 fi
 
 ################################################################################
+AC_CHECK_LIB(m, log10,
+	[M_LIBS="-lm"], hard_bailout)
+
+################################################################################
 AC_CHECK_LIB([pthread], [pthread_mutex_lock],
 	[PTHREAD_LIBS="-lpthread"], hard_bailout)
 
@@ -1984,6 +1988,7 @@ AC_SUBST(OCF)
 AC_SUBST(OCFDIR)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
+AC_SUBST(M_LIBS)
 AC_SUBST(PTHREAD_LIBS)
 AC_SUBST(PYTHON)
 AC_SUBST(PYTHON_BINDINGS)
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 880b40c..1b924ce 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -55,7 +55,7 @@ include $(top_builddir)/make.tmpl
 
 CFLAGS += $(UDEV_CFLAGS) $(VALGRIND_CFLAGS)
 
-LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS)
+LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS) $(M_LIBS)
 
 device-mapper: all
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 731dab7..e4f8835 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -54,6 +54,7 @@ LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
 LVMINTERNAL_LIBS = -llvm-internal $(DAEMON_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
+M_LIBS = @M_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@


