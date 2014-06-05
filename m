From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jun 2014 15:54:20 +0000 (UTC)
Subject: master - man: document DM_DEFAULT_NAME_MANGLING_MODE
Message-ID: <20140605155420.83DCD610E9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93c2614e566c1aafae178c34838da21caf8ea16a
Commit:        93c2614e566c1aafae178c34838da21caf8ea16a
Parent:        4454a580dfd966d0cd132a2fd7d0cbb0df7e46a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 5 17:26:53 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 17:47:21 2014 +0200

man: document DM_DEFAULT_NAME_MANGLING_MODE

Document DM_DEFAULT_NAME_MANGLING_MODE environmental variable.
(its default setting is build time configurable)
---
 WHATS_NEW_DM     |    1 +
 configure.in     |    3 ++-
 make.tmpl.in     |    3 ++-
 man/Makefile.in  |    2 +-
 man/dmsetup.8.in |    9 ++++++++-
 5 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8e221c1..976f927 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.88 - 
 =================================
+  Document env var 'DM_DEFAULT_NAME_MANGLING_MODE' in dmsetup man page.
   Warn user about incorrect use of cookie with 'dmsetup remove --force'.
   Also recognize 'help'/'?' as reserved sort key name to show help.
   Export recognized DM_REPORT_FIELD_RESERVED_NAME_{HELP,HELP_ALT} to show help.
diff --git a/configure.in b/configure.in
index 16e63c0..807ad32 100644
--- a/configure.in
+++ b/configure.in
@@ -1,6 +1,6 @@
 ###############################################################################
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+## Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
 ##
 ## This copyrighted material is made available to anyone wishing to use,
 ## modify, copy, or redistribute it subject to the terms and conditions
@@ -1725,6 +1725,7 @@ AC_SUBST(LVM_PATCHLEVEL)
 AC_SUBST(LVM_PATH)
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
+AC_SUBST(MANGLING)
 AC_SUBST(MIRRORS)
 AC_SUBST(MSGFMT)
 AC_SUBST(OCF)
diff --git a/make.tmpl.in b/make.tmpl.in
index cb5b826..5a3694a 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -1,7 +1,7 @@
 # @configure_input@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -102,6 +102,7 @@ DEFAULT_CACHE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_CACHE_SUBDIR@
 DEFAULT_PROFILE_DIR = $(DEFAULT_SYS_DIR)/@DEFAULT_PROFILE_SUBDIR@
 DEFAULT_LOCK_DIR = @DEFAULT_LOCK_DIR@
 DEFAULT_RUN_DIR = @DEFAULT_RUN_DIR@
+DEFAULT_MANGLING = @MANGLING@
 
 # Setup vpath search paths for some suffixes
 vpath %.c $(srcdir)
diff --git a/man/Makefile.in b/man/Makefile.in
index 15f0252..5a11ae2 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -99,7 +99,7 @@ $(MAN5) $(MAN7) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
 %: %.in
 	@case "$@" in \
 	  */*) ;; \
-	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;s+#DEFAULT_PID_DIR#+ at DEFAULT_PID_DIR@+;s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+;" $< > $@ ;; \
+	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;s+#DEFAULT_PID_DIR#+ at DEFAULT_PID_DIR@+;s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+;s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+;" $< > $@ ;; \
 	esac
 
 install_man5: $(MAN5)
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 9a738fb..1b17580 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -202,6 +202,9 @@ mangled, error on mixed; this is used by default).
 Character whitelist: 0-9, A-Z, a-z, #+-.:=@_. This whitelist is
 also supported by udev. Any character not on a whitelist is replaced
 with its hex value (two digits) prefixed by \\x.
+Mangling mode could be also set through
+.B DM_DEFAULT_NAME_MANGLING_MODE
+environment variable.
 .TP
 .BR \-j | \-\-major\ \fImajor
 Specify the major number.
@@ -712,7 +715,11 @@ Defaults to "/dev" and must be an absolute path.
 .TP
 .B DM_UDEV_COOKIE
 A cookie to use for all relevant commands to synchronize with udev processing.
-It is an alternative to using \-\-udevcookie option.
+It is an alternative to using \fB\-\-udevcookie\fP option.
+.TP
+.B DM_DEFAULT_NAME_MANGLING_MODE
+A default mangling mode. Defaults to "#DEFAULT_MANGLING#"
+and it is an alternative to using \fB\-\-manglename\fP option.
 
 .SH AUTHORS
 Original version: Joe Thornber (thornber at redhat.com)


