From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 Jul 2012 14:49:08 +0000 (UTC)
Subject: master - systemd: integrate lvm2 activation generator with conf+make
Message-ID: <20120731144908.28C223171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa68466e904568d054f0b0cf5fdab6499cb47998
Commit:        fa68466e904568d054f0b0cf5fdab6499cb47998
Parent:        d3e67ba8ca13115ffdd324e64e965240dced8ef1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 31 16:46:24 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 31 16:46:24 2012 +0200

systemd: integrate lvm2 activation generator with conf+make

---
 Makefile.in         |    7 ++++++-
 WHATS_NEW           |    2 ++
 configure           |    9 ++++++++-
 configure.in        |    8 +++++++-
 make.tmpl.in        |    3 ++-
 scripts/Makefile.in |   26 ++++++++++++++++++++------
 6 files changed, 45 insertions(+), 10 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 5e0b348..04746d1 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -16,7 +16,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SUBDIRS = doc include man scripts
+SUBDIRS = doc include man
 
 ifeq ("@UDEV_RULES@", "yes")
   SUBDIRS += udev
@@ -36,6 +36,8 @@ ifeq ("@BUILD_LVMETAD@", "yes")
   SUBDIRS += libdaemon
 endif
 
+SUBDIRS += scripts
+
 # FIXME Should use intermediate Makefiles here!
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = doc include man scripts \
@@ -98,6 +100,9 @@ install_system_dirs:
 install_initscripts: 
 	$(MAKE) -C scripts install_initscripts
 
+install_systemd_generators:
+	$(MAKE) -C scripts install_systemd_generators
+
 install_systemd_units:
 	$(MAKE) -C scripts install_systemd_units
 
diff --git a/WHATS_NEW b/WHATS_NEW
index 5208da9..92dd0dc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.97 - 
 ===============================
+  Add make install_systemd_generators.
+  Add generator for lvm2 activation systemd units.
   Add lvm_config_find_bool lvm2app fn to retrieve bool value from config tree.
   Respect --test also when using lvmetad.
   No longer capitalise first LV attribute char for invalid snapshots.
diff --git a/configure b/configure
index ca71fdb..52f0e36 100755
--- a/configure
+++ b/configure
@@ -597,6 +597,7 @@ ac_subst_vars='LTLIBOBJS
 usrsbindir
 usrlibdir
 tmpfilesdir
+systemdutildir
 systemdsystemunitdir
 udevdir
 udev_prefix
@@ -9917,7 +9918,12 @@ if test -n "$pkg_systemdsystemunitdir"; then
 fi
 
 if test -z "$systemdsystemunitdir"; then
-	    systemdsystemunitdir='/lib/systemd/system';
+	    systemdsystemunitdir='${exec_prefix}/lib/systemd/system';
+fi
+
+systemdutildir=$($PKG_CONFIG --variable=systemdutildir systemd)
+if test -z "$systemdutildir"; then
+	    systemdutildir='${exec_prefix}/lib/systemd';
 fi
 ################################################################################
 
@@ -10566,6 +10572,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_l
 vmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index 8bf0c4e..1c908f9 100644
--- a/configure.in
+++ b/configure.in
@@ -1275,7 +1275,12 @@ if test -n "$pkg_systemdsystemunitdir"; then
 fi
 
 if test -z "$systemdsystemunitdir"; then
-	    systemdsystemunitdir='/lib/systemd/system';
+	    systemdsystemunitdir='${exec_prefix}/lib/systemd/system';
+fi
+
+systemdutildir=$($PKG_CONFIG --variable=systemdutildir systemd)
+if test -z "$systemdutildir"; then
+	    systemdutildir='${exec_prefix}/lib/systemd';
 fi
 ################################################################################
 AC_ARG_WITH(tmpfilesdir,
@@ -1549,6 +1554,7 @@ AC_SUBST(tmpdir)
 AC_SUBST(udev_prefix)
 AC_SUBST(udevdir)
 AC_SUBST(systemdsystemunitdir)
+AC_SUBST(systemdutildir)
 AC_SUBST(tmpfilesdir)
 AC_SUBST(usrlibdir)
 AC_SUBST(usrsbindir)
diff --git a/make.tmpl.in b/make.tmpl.in
index 25cc87f..b8b127f 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -67,7 +67,8 @@ staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
 initdir = $(DESTDIR)$(sysconfdir)/rc.d/init.d
-systemd_dir = $(DESTDIR)@systemdsystemunitdir@
+systemd_unit_dir = $(DESTDIR)@systemdsystemunitdir@
+systemd_generator_dir = $(DESTDIR)@systemdutildir@/system-generators
 tmpfiles_dir = $(DESTDIR)@tmpfilesdir@
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
 
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 53c85f5..40396b0 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -15,9 +15,16 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
+SOURCES = lvm2_activation_generator_systemd_red_hat.c
+TARGETS = lvm2_activation_generator_systemd_red_hat
+
 include $(top_builddir)/make.tmpl
 
+DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
+LVMLIBS = @LVM2APP_LIB@ -ldevmapper
+
 SCRIPTS = lvmdump.sh lvmconf.sh vgimportclone.sh
+
 ifeq ("@FSADM@", "yes")
 	SCRIPTS += fsadm.sh
 endif
@@ -59,16 +66,23 @@ ifeq ("@BUILD_CMIRRORD@", "yes")
 	$(INSTALL_SCRIPT) cmirrord_init_red_hat $(initdir)/cmirrord
 endif
 
+lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS)
+	$(CC) -o $@ $(OBJECTS) $(LVMLIBS)
+
+install_systemd_generators:
+	$(INSTALL_DIR) $(systemd_generator_dir)
+	$(INSTALL_PROGRAM) lvm2_activation_generator_systemd_red_hat $(systemd_generator_dir)/lvm2-activation-generator
+
 install_systemd_units:
-	$(INSTALL_DIR) $(systemd_dir)
+	$(INSTALL_DIR) $(systemd_unit_dir)
 ifeq ("@BUILD_DMEVENTD@", "yes")
-	$(INSTALL_DATA) dm_event_systemd_red_hat.socket $(systemd_dir)/dm-event.socket
-	$(INSTALL_DATA) dm_event_systemd_red_hat.service $(systemd_dir)/dm-event.service
-	$(INSTALL_DATA) lvm2_monitoring_systemd_red_hat.service $(systemd_dir)/lvm2-monitor.service
+	$(INSTALL_DATA) dm_event_systemd_red_hat.socket $(systemd_unit_dir)/dm-event.socket
+	$(INSTALL_DATA) dm_event_systemd_red_hat.service $(systemd_unit_dir)/dm-event.service
+	$(INSTALL_DATA) lvm2_monitoring_systemd_red_hat.service $(systemd_unit_dir)/lvm2-monitor.service
 endif
 ifeq ("@BUILD_LVMETAD@", "yes")
-	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.socket $(systemd_dir)/lvm2-lvmetad.socket
-	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.service $(systemd_dir)/lvm2-lvmetad.service
+	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.socket $(systemd_unit_dir)/lvm2-lvmetad.socket
+	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmetad.service
 endif
 
 install_tmpfiles_configuration:


