From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 13:31:05 +0000 (UTC)
Subject: master - configure: update recent change
Message-ID: <20131212133105.C323460F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b424b6398be64aec6a5772bb847f78b1941a0fe1
Commit:        b424b6398be64aec6a5772bb847f78b1941a0fe1
Parent:        fd0068a66ee8f8ad03ac0c86b9ab3f6a8a368ac9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 12 14:29:15 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 14:29:15 2013 +0100

configure: update recent change

Full path needs to be supplied.
Keep on using 'autodetect' keyword as default argument.
---
 configure.in |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/configure.in b/configure.in
index cf297e8..3e0e508 100644
--- a/configure.in
+++ b/configure.in
@@ -413,16 +413,16 @@ AC_ARG_WITH(thin,
 	    THIN=$withval, THIN=internal)
 AC_ARG_WITH(thin-check,
 	    AC_HELP_STRING([--with-thin-check=PATH],
-			   [thin_check tool: [[thin_check]]]),
-			   THIN_CHECK_CMD=$withval, THIN_CHECK_CMD="thin_check")
+			   [thin_check tool: [[autodetect]]]),
+			   THIN_CHECK_CMD=$withval, THIN_CHECK_CMD="autodetect")
 AC_ARG_WITH(thin-dump,
 	    AC_HELP_STRING([--with-thin-dump=PATH],
-			   [thin_dump tool: [[thin_dump]]]),
-			   THIN_DUMP_CMD=$withval, THIN_DUMP_CMD="thin_dump")
+			   [thin_dump tool: [[autodetect]]]),
+			   THIN_DUMP_CMD=$withval, THIN_DUMP_CMD="autodetect")
 AC_ARG_WITH(thin-repair,
 	    AC_HELP_STRING([--with-thin-repair=PATH],
-			   [thin_repair tool: [[thin_repair]]]),
-			   THIN_REPAIR_CMD=$withval, THIN_REPAIR_CMD="thin_repair")
+			   [thin_repair tool: [[autodetect]]]),
+			   THIN_REPAIR_CMD=$withval, THIN_REPAIR_CMD="autodetect")
 
 AC_MSG_RESULT($THIN)
 
@@ -438,29 +438,29 @@ esac
 case "$THIN" in
   internal|shared)
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_CHECK_CMD" = "thin_check"; then
-		AC_PATH_TOOL(THIN_CHECK_CMD, thin_check, thin_check)
-		test "$THIN_CHECK_CMD" = "thin_check" && {
+	if test "$THIN_CHECK_CMD" = "autodetect"; then
+		AC_PATH_TOOL(THIN_CHECK_CMD, thin_check)
+		test -z "$THIN_CHECK_CMD" && {
 			AC_MSG_WARN([thin_check not found in path $PATH])
-			THIN_CHECK_CMD=thin_check
+			THIN_CHECK_CMD=/usr/sbin/thin_check
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_DUMP_CMD" = "thin_dump"; then
-		AC_PATH_TOOL(THIN_DUMP_CMD, thin_dump, thin_dump)
-		test "$THIN_DUMP_CMD" = "thin_dump" && {
+	if test "$THIN_DUMP_CMD" = "autodetect"; then
+		AC_PATH_TOOL(THIN_DUMP_CMD, thin_dump)
+		test -z "$THIN_DUMP_CMD" && {
 			AC_MSG_WARN(thin_dump not found in path $PATH)
-			THIN_DUMP_CMD=thin_dump
+			THIN_DUMP_CMD=/usr/sbin/thin_dump
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_REPAIR_CMD" = "thin_repair"; then
+	if test "$THIN_REPAIR_CMD" = "autodetect"; then
 		AC_PATH_TOOL(THIN_REPAIR_CMD, thin_repair)
 		test -z "$THIN_REPAIR_CMD" && {
 			AC_MSG_WARN(thin_repair not found in path $PATH)
-			THIN_REPAIR_CMD=thin_repair
+			THIN_REPAIR_CMD=/usr/sbin/thin_repair
 			THIN_CONFIGURE_WARN=y
 		}
 	fi


