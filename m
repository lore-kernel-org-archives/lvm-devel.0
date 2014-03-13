From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu, 13 Mar 2014 23:40:53 +0000 (UTC)
Subject: master - man: Fix man page containing BUILDROOT
Message-ID: <20140313234053.644E060F80@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a31ab7c1716b60d80cbc1b58fa08b7ef9f1b8183
Commit:        a31ab7c1716b60d80cbc1b58fa08b7ef9f1b8183
Parent:        2189d66a2758e4be67a32a7d9d24a9df55c31c4c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Mar 14 00:36:19 2014 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Mar 14 00:36:19 2014 +0100

man: Fix man page containing BUILDROOT

This breaks brew/koji as DESTDIR should not be contained in any file and
results in message like:

    + /usr/lib/rpm/check-buildroot
    /builddir/build/BUILDROOT/lvm2-2.02.106-0.311.el7.x86_64/usr/share/man/man8/lvm2-activation-generator.8:.B /builddir/build/BUILDROOT/lvm2-2.02.106-0.311.el7.x86_64/usr/lib/systemd/system-generators/lvm2-activation-generator
    Found '/builddir/build/BUILDROOT/lvm2-2.02.106-0.311.el7.x86_64' in installed files; aborting
    error: Bad exit status from /var/tmp/rpm-tmp.UfX2SX (%install)
---
 make.tmpl.in    |    3 ++-
 man/Makefile.in |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index b1a6b8f..cb5b826 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -85,7 +85,7 @@ udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
 initdir = $(DESTDIR)$(sysconfdir)/rc.d/init.d
 systemd_unit_dir = $(DESTDIR)@systemdsystemunitdir@
-systemd_generator_dir = $(DESTDIR)@systemdutildir@/system-generators
+systemd_generator_dir = $(DESTDIR)$(SYSTEMD_GENERATOR_DIR)
 systemd_dir = $(DESTDIR)@systemdutildir@
 tmpfiles_dir = $(DESTDIR)@tmpfilesdir@
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
@@ -94,6 +94,7 @@ pyexecdir = $(DESTDIR)$(prefix)
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
   $(AWK) -f $(top_srcdir)/scripts/relpath.awk)
 
+SYSTEMD_GENERATOR_DIR = @systemdutildir@/system-generators
 DEFAULT_SYS_DIR = @DEFAULT_SYS_DIR@
 DEFAULT_ARCHIVE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_ARCHIVE_SUBDIR@
 DEFAULT_BACKUP_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_BACKUP_SUBDIR@
diff --git a/man/Makefile.in b/man/Makefile.in
index ce3b1ee..40145f1 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -87,7 +87,7 @@ $(MAN5) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
 %: %.in
 	@case "$@" in \
 	  */*) ;; \
-	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;s+#SYSTEMD_GENERATOR_DIR#+$(systemd_generator_dir)+;" $< > $@ ;; \
+	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+;" $< > $@ ;; \
 	esac
 
 install_man5: $(MAN5)


