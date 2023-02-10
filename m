From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 19:56:13 +0000 (GMT)
Subject: main - configure.ac: support systemd-run binary path
Message-ID: <20230210195613.3B8EF385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=391138ff303c85999782e1341a5e1d8a28810486
Commit:        391138ff303c85999782e1341a5e1d8a28810486
Parent:        2a72f8a49cf6601db7c987c7c4d6a72a29a59a1e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 19:49:42 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 20:54:05 2023 +0100

configure.ac: support systemd-run binary path

Allow users to specify their path to systemd-run binary:

configure --with-systemd-run=/my/path/system-run

By defaults it autodetected in $PATH and fallbacks to:
/usr/bin/systemd-run.
---
 configure.ac            | 14 ++++++++++++++
 udev/69-dm-lvm.rules.in |  2 +-
 udev/Makefile.in        |  6 +++---
 3 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/configure.ac b/configure.ac
index 49b06145d..3177012e2 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1101,6 +1101,19 @@ AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes" || test "$SYSTEMD_JOURNAL_SUPPORT" = "
 	PKG_CHECK_MODULES(SYSTEMD, [systemd], [SYSTEMD_LIBS="-lsystemd"], $bailout)
 ])
 
+################################################################################
+dnl -- Support override for systemd-run path if they need to (NixOS builds)
+AC_ARG_WITH(systemd-run,
+	    AS_HELP_STRING([--with-systemd-run=PATH],
+			   [systemd-run tool: [autodetect]]),
+			   SYSTEMD_RUN_CMD=$withval, SYSTEMD_RUN_CMD="autodetect")
+
+AS_IF([test "$SYSTEMD_RUN_CMD" = "autodetect"],
+      [AC_PATH_TOOL(SYSTEMD_RUN_CMD, systemd-run)
+       AS_IF([test -z "$SYSTEMD_RUN_CMD"], [SYSTEMD_RUN_CMD="/usr/bin/systemd-run"])],
+      [AC_MSG_CHECKING([for defined systemd-run])
+       AC_MSG_RESULT([$SYSTEMD_RUN_CMD])])
+
 ################################################################################
 
 dnl -- Enable blkid wiping functionality
@@ -1908,6 +1921,7 @@ AC_SUBST(SBINDIR)
 AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SELINUX_PC)
 AC_SUBST(SYSCONFDIR)
+AC_SUBST(SYSTEMD_RUN_CMD)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
diff --git a/udev/69-dm-lvm.rules.in b/udev/69-dm-lvm.rules.in
index 3cda30023..ff1568145 100644
--- a/udev/69-dm-lvm.rules.in
+++ b/udev/69-dm-lvm.rules.in
@@ -76,7 +76,7 @@ LABEL="lvm_scan"
 # it's better suited to appearing in the journal.
 
 IMPORT{program}="(LVM_EXEC)/lvm pvscan --cache --listvg --checkcomplete --vgonline --autoactivation event --udevoutput --journal=output $env{DEVNAME}"
-ENV{LVM_VG_NAME_COMPLETE}=="?*", RUN+="/usr/bin/systemd-run --no-block --property DefaultDependencies=no --unit lvm-activate-$env{LVM_VG_NAME_COMPLETE} (LVM_EXEC)/lvm vgchange -aay --autoactivation event $env{LVM_VG_NAME_COMPLETE}"
+ENV{LVM_VG_NAME_COMPLETE}=="?*", RUN+="(SYSTEMDRUN) --no-block --property DefaultDependencies=no --unit lvm-activate-$env{LVM_VG_NAME_COMPLETE} (LVM_EXEC)/lvm vgchange -aay --autoactivation event $env{LVM_VG_NAME_COMPLETE}"
 GOTO="lvm_end"
 
 LABEL="lvm_end"
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 106fca113..5ee30d09c 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2009-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2023 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -22,7 +22,7 @@ LVM_RULES=11-dm-lvm.rules 69-dm-lvm.rules
 
 DM_DIR=$(shell $(GREP) "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | $(AWK) '{print $$3}')
 
-BINDIR=@bindir@
+SYSTEMDRUN=@SYSTEMD_RUN_CMD@
 ifeq ("@UDEV_RULE_EXEC_DETECTION@", "yes")
 SBIN=\$$env{DM_SBIN_PATH}
 DM_EXEC_RULE=ENV{DM_SBIN_PATH}=\"\/sbin\"\\nTEST!=\"\$$env{DM_SBIN_PATH}\/dmsetup\", ENV{DM_SBIN_PATH}=\"\/usr\/sbin\"
@@ -44,7 +44,7 @@ BLKID_RULE=IMPORT{program}=\"${SBIN}\/blkid -o udev -p \$$tempnode\"
 endif
 
 %.rules: $(srcdir)/%.rules.in
-	$(Q) $(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BINDIR)+$(BINDIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
+	$(Q) $(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(SYSTEMDRUN)+$(SYSTEMDRUN)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
 
 %_install: %.rules
 	@echo "    [INSTALL] $<"

