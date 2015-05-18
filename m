From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 May 2015 17:03:08 +0000 (UTC)
Subject: master - configure: update localedir
Message-ID: <20150518170308.5C23760C9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc49e1cde0a0736c581b10062797807c65ae0ce3
Commit:        dc49e1cde0a0736c581b10062797807c65ae0ce3
Parent:        aa2d39c2ca720d9443c2682311945d56ab9a0559
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 18 18:13:07 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 18 18:48:18 2015 +0200

configure: update localedir

Previous patch incorrectly skipped replace of @LOCALEDIR at .

The standard option is --localedir  so use --with-localedir
as backward compatible option and set localedir if it's not
yet been set (if the could ever happen).

Use double-eval to translate $datarootdir to $prefix to real dir.
---
 configure               |   10 ++++++----
 configure.in            |    8 +++++---
 lib/misc/configure.h.in |    2 +-
 make.tmpl.in            |    2 +-
 4 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/configure b/configure
index 9cd225a..6d5abc4 100755
--- a/configure
+++ b/configure
@@ -1724,7 +1724,7 @@ Optional Packages:
                           lvmetad pidfile [PID_DIR/lvmetad.pid]
   --with-lvmpolld-pidfile=PATH
                           lvmpolld pidfile [PID_DIR/lvmpolld.pid]
-  --with-localedir=DIR    translation files in DIR [PREFIX/share/locale]
+  --with-localedir=DIR    locale-dependent data [DATAROOTDIR/locale]
   --with-confdir=DIR      configuration files in DIR [/etc]
   --with-staticdir=DIR    static binaries in DIR [EPREFIX/sbin]
   --with-usrlibdir=DIR    usrlib in DIR [PREFIX/lib]
@@ -12432,9 +12432,9 @@ fi
 
 # Check whether --with-localedir was given.
 if test "${with_localedir+set}" = set; then :
-  withval=$with_localedir; LOCALEDIR=$withval
+  withval=$with_localedir; localedir=$withval
 else
-  LOCALEDIR="${prefix}/share/locale"
+  localedir=${localedir-'${datarootdir}/locale'}
 fi
 
 
@@ -12442,9 +12442,10 @@ cat >>confdefs.h <<_ACEOF
 #define INTL_PACKAGE "$INTL_PACKAGE"
 _ACEOF
 
+	# double eval needed ${datarootdir} -> ${prefix}/share -> real path
 
 cat >>confdefs.h <<_ACEOF
-#define LOCALEDIR "$LOCALEDIR"
+#define LOCALEDIR "$(eval echo $(eval echo $localedir))"
 _ACEOF
 
 fi
@@ -13264,6 +13265,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile 
 liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat@.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/
 Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
diff --git a/configure.in b/configure.in
index d31c431..75af936 100644
--- a/configure.in
+++ b/configure.in
@@ -1516,10 +1516,11 @@ if test "$INTL" = yes; then
 
 	AC_ARG_WITH(localedir,
 		    AC_HELP_STRING([--with-localedir=DIR],
-				   [translation files in DIR [PREFIX/share/locale]]),
-		    LOCALEDIR=$withval, LOCALEDIR="${prefix}/share/locale")
+				   [locale-dependent data [DATAROOTDIR/locale]]),
+		    localedir=$withval, localedir=${localedir-'${datarootdir}/locale'})
 	AC_DEFINE_UNQUOTED([INTL_PACKAGE], ["$INTL_PACKAGE"], [Internalization package])
-	AC_DEFINE_UNQUOTED([LOCALEDIR], ["$LOCALEDIR"], [Location of translation files])
+	# double eval needed ${datarootdir} -> ${prefix}/share -> real path
+	AC_DEFINE_UNQUOTED([LOCALEDIR], ["$(eval echo $(eval echo $localedir))"], [Locale-dependent data])
 fi
 
 ################################################################################
@@ -1813,6 +1814,7 @@ AC_SUBST(LVM_PATCHLEVEL)
 AC_SUBST(LVM_PATH)
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
+AC_SUBST(localedir)
 AC_SUBST(MANGLING)
 AC_SUBST(MIRRORS)
 AC_SUBST(MSGFMT)
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 986b2bc..3af8ec0 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -507,7 +507,7 @@
 /* Internalization package */
 #undef INTL_PACKAGE
 
-/* Location of translation files */
+/* Locale-dependent data */
 #undef LOCALEDIR
 
 /* Define to 1 if `lstat' dereferences a symlink specified with a trailing
diff --git a/make.tmpl.in b/make.tmpl.in
index 95ca299..806bde4 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -82,7 +82,7 @@ datarootdir = @datarootdir@
 datadir = $(DESTDIR)@datadir@
 infodir = $(DESTDIR)@infodir@
 mandir = $(DESTDIR)@mandir@
-localedir = $(DESTDIR)@LOCALEDIR@
+localedir = $(DESTDIR)@localedir@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig


