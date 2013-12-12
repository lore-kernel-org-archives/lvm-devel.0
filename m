From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 12:43:36 +0000 (UTC)
Subject: master - thin: enable build of thin provisioning by default
Message-ID: <20131212124336.C68EC6024C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10a13dc03cd4da2df3518f7a94014f167ec13d47
Commit:        10a13dc03cd4da2df3518f7a94014f167ec13d47
Parent:        9fcbe3c6f074443248922b61441bb2b37253a59c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 12 13:07:59 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 13:31:23 2013 +0100

thin: enable build of thin provisioning by default

Use internal type by default for thin provisioning.
If user is not interested in thin provisiong and doesn't
have thin provisining supporting tools installed,
configure will just print warning at the end of configure
process about limited support.
---
 WHATS_NEW    |    1 +
 configure.in |   65 ++++++++++++++++++++++++++++++++++++---------------------
 2 files changed, 42 insertions(+), 24 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4b469d4..704d0be 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Enable support for thin provisioning for default configuration.
   Improve process_each_lv_in_vg() tag processing.
   Reodered and simplified logging code.
   Fix SYSTEMD_READY assignment for foreign devices in lvmetad udev rules.
diff --git a/configure.in b/configure.in
index 851d3f7..cf297e8 100644
--- a/configure.in
+++ b/configure.in
@@ -1,6 +1,6 @@
 ###############################################################################
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+## Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
 ##
 ## This copyrighted material is made available to anyone wishing to use,
 ## modify, copy, or redistribute it subject to the terms and conditions
@@ -409,8 +409,21 @@ AC_MSG_CHECKING(whether to include thin provisioning)
 AC_ARG_WITH(thin,
 	    AC_HELP_STRING([--with-thin=TYPE],
 			   [thin provisioning support: internal/shared/none
-			    [[TYPE=none]]]),
-	    THIN=$withval, THIN=none)
+			    [[TYPE=internal]]]),
+	    THIN=$withval, THIN=internal)
+AC_ARG_WITH(thin-check,
+	    AC_HELP_STRING([--with-thin-check=PATH],
+			   [thin_check tool: [[thin_check]]]),
+			   THIN_CHECK_CMD=$withval, THIN_CHECK_CMD="thin_check")
+AC_ARG_WITH(thin-dump,
+	    AC_HELP_STRING([--with-thin-dump=PATH],
+			   [thin_dump tool: [[thin_dump]]]),
+			   THIN_DUMP_CMD=$withval, THIN_DUMP_CMD="thin_dump")
+AC_ARG_WITH(thin-repair,
+	    AC_HELP_STRING([--with-thin-repair=PATH],
+			   [thin_repair tool: [[thin_repair]]]),
+			   THIN_REPAIR_CMD=$withval, THIN_REPAIR_CMD="thin_repair")
+
 AC_MSG_RESULT($THIN)
 
 case "$THIN" in
@@ -420,34 +433,36 @@ case "$THIN" in
   *) AC_MSG_ERROR([--with-thin parameter invalid ($THIN)]) ;;
 esac
 
+# Test if necessary thin tools are available
+# if not - use plain defaults and warn user
 case "$THIN" in
   internal|shared)
-	AC_ARG_WITH(thin-check,
-		AC_HELP_STRING([--with-thin-check=PATH],
-			       [thin_check tool: [[autodetect]]]),
-			       THIN_CHECK_CMD=$withval, THIN_CHECK_CMD="autodetect")
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_CHECK_CMD" = "autodetect"; then
-		AC_PATH_PROG(THIN_CHECK_CMD, thin_check)
-		test -z "$THIN_CHECK_CMD" && AC_MSG_ERROR(thin_check not found in path $PATH)
+	if test "$THIN_CHECK_CMD" = "thin_check"; then
+		AC_PATH_TOOL(THIN_CHECK_CMD, thin_check, thin_check)
+		test "$THIN_CHECK_CMD" = "thin_check" && {
+			AC_MSG_WARN([thin_check not found in path $PATH])
+			THIN_CHECK_CMD=thin_check
+			THIN_CONFIGURE_WARN=y
+		}
 	fi
-	AC_ARG_WITH(thin-dump,
-		AC_HELP_STRING([--with-thin-dump=PATH],
-			       [thin_dump tool: [[autodetect]]]),
-			       THIN_DUMP_CMD=$withval, THIN_DUMP_CMD="autodetect")
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_DUMP_CMD" = "autodetect"; then
-		AC_PATH_PROG(THIN_DUMP_CMD, thin_dump)
-		test -z "$THIN_DUMP_CMD" && AC_MSG_ERROR(thin_dump not found in path $PATH)
+	if test "$THIN_DUMP_CMD" = "thin_dump"; then
+		AC_PATH_TOOL(THIN_DUMP_CMD, thin_dump, thin_dump)
+		test "$THIN_DUMP_CMD" = "thin_dump" && {
+			AC_MSG_WARN(thin_dump not found in path $PATH)
+			THIN_DUMP_CMD=thin_dump
+			THIN_CONFIGURE_WARN=y
+		}
 	fi
-	AC_ARG_WITH(thin-repair,
-		AC_HELP_STRING([--with-thin-repair=PATH],
-			       [thin_repair tool: [[autodetect]]]),
-			       THIN_REPAIR_CMD=$withval, THIN_REPAIR_CMD="autodetect")
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_REPAIR_CMD" = "autodetect"; then
-		AC_PATH_PROG(THIN_REPAIR_CMD, thin_repair)
-		test -z "$THIN_REPAIR_CMD" && AC_MSG_ERROR(thin_repair not found in path $PATH)
+	if test "$THIN_REPAIR_CMD" = "thin_repair"; then
+		AC_PATH_TOOL(THIN_REPAIR_CMD, thin_repair)
+		test -z "$THIN_REPAIR_CMD" && {
+			AC_MSG_WARN(thin_repair not found in path $PATH)
+			THIN_REPAIR_CMD=thin_repair
+			THIN_CONFIGURE_WARN=y
+		}
 	fi
 	;;
 esac
@@ -1774,6 +1789,8 @@ unit-tests/mm/Makefile
 ])
 AC_OUTPUT
 
+test -n "$THIN_CONFIGURE_WARN" && AC_MSG_WARN([Support for thin provisioning is limited since some thin provisioning tools are missing!])
+
 if test x$ODIRECT != xyes; then
   AC_MSG_WARN(Warning: O_DIRECT disabled: low-memory pvmove may lock up)
 fi


