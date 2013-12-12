From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 12 Dec 2013 13:32:46 +0000 (UTC)
Subject: master - autoreconf: latest changes
Message-ID: <20131212133246.E190D60573@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=131693c42143505f969821b7f2cab0bff471c620
Commit:        131693c42143505f969821b7f2cab0bff471c620
Parent:        b424b6398be64aec6a5772bb847f78b1941a0fe1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 12 14:32:11 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 12 14:32:40 2013 +0100

autoreconf: latest changes

---
 configure |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/configure b/configure
index f48c89b..a156460 100755
--- a/configure
+++ b/configure
@@ -1619,9 +1619,9 @@ Optional Packages:
                           [[TYPE=none]]
   --with-thin=TYPE        thin provisioning support: internal/shared/none
                           [[TYPE=internal]]
-  --with-thin-check=PATH  thin_check tool: [[thin_check]]
-  --with-thin-dump=PATH   thin_dump tool: [[thin_dump]]
-  --with-thin-repair=PATH thin_repair tool: [[thin_repair]]
+  --with-thin-check=PATH  thin_check tool: [[autodetect]]
+  --with-thin-dump=PATH   thin_dump tool: [[autodetect]]
+  --with-thin-repair=PATH thin_repair tool: [[autodetect]]
   --with-ocfdir=DIR       install OCF files in DIR
                           [[PREFIX/lib/ocf/resource.d/lvm2]]
   --with-default-pid-dir=PID_DIR
@@ -7154,7 +7154,7 @@ fi
 if test "${with_thin_check+set}" = set; then :
   withval=$with_thin_check; THIN_CHECK_CMD=$withval
 else
-  THIN_CHECK_CMD="thin_check"
+  THIN_CHECK_CMD="autodetect"
 fi
 
 
@@ -7162,7 +7162,7 @@ fi
 if test "${with_thin_dump+set}" = set; then :
   withval=$with_thin_dump; THIN_DUMP_CMD=$withval
 else
-  THIN_DUMP_CMD="thin_dump"
+  THIN_DUMP_CMD="autodetect"
 fi
 
 
@@ -7170,7 +7170,7 @@ fi
 if test "${with_thin_repair+set}" = set; then :
   withval=$with_thin_repair; THIN_REPAIR_CMD=$withval
 else
-  THIN_REPAIR_CMD="thin_repair"
+  THIN_REPAIR_CMD="autodetect"
 fi
 
 
@@ -7190,7 +7190,7 @@ esac
 case "$THIN" in
   internal|shared)
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_CHECK_CMD" = "thin_check"; then
+	if test "$THIN_CHECK_CMD" = "autodetect"; then
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_check", so it can be a program name with args.
 set dummy ${ac_tool_prefix}thin_check; ac_word=$2
@@ -7275,7 +7275,7 @@ $as_echo "no" >&6; }
 fi
 
   if test "x$ac_pt_THIN_CHECK_CMD" = x; then
-    THIN_CHECK_CMD="thin_check"
+    THIN_CHECK_CMD=""
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
@@ -7289,15 +7289,15 @@ else
   THIN_CHECK_CMD="$ac_cv_path_THIN_CHECK_CMD"
 fi
 
-		test "$THIN_CHECK_CMD" = "thin_check" && {
+		test -z "$THIN_CHECK_CMD" && {
 			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_check not found in path $PATH" >&5
 $as_echo "$as_me: WARNING: thin_check not found in path $PATH" >&2;}
-			THIN_CHECK_CMD=thin_check
+			THIN_CHECK_CMD=/usr/sbin/thin_check
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_DUMP_CMD" = "thin_dump"; then
+	if test "$THIN_DUMP_CMD" = "autodetect"; then
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_dump", so it can be a program name with args.
 set dummy ${ac_tool_prefix}thin_dump; ac_word=$2
@@ -7382,7 +7382,7 @@ $as_echo "no" >&6; }
 fi
 
   if test "x$ac_pt_THIN_DUMP_CMD" = x; then
-    THIN_DUMP_CMD="thin_dump"
+    THIN_DUMP_CMD=""
   else
     case $cross_compiling:$ac_tool_warned in
 yes:)
@@ -7396,15 +7396,15 @@ else
   THIN_DUMP_CMD="$ac_cv_path_THIN_DUMP_CMD"
 fi
 
-		test "$THIN_DUMP_CMD" = "thin_dump" && {
+		test -z "$THIN_DUMP_CMD" && {
 			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_dump not found in path $PATH" >&5
 $as_echo "$as_me: WARNING: thin_dump not found in path $PATH" >&2;}
-			THIN_DUMP_CMD=thin_dump
+			THIN_DUMP_CMD=/usr/sbin/thin_dump
 			THIN_CONFIGURE_WARN=y
 		}
 	fi
 	# Empty means a config way to ignore thin checking
-	if test "$THIN_REPAIR_CMD" = "thin_repair"; then
+	if test "$THIN_REPAIR_CMD" = "autodetect"; then
 		if test -n "$ac_tool_prefix"; then
   # Extract the first word of "${ac_tool_prefix}thin_repair", so it can be a program name with args.
 set dummy ${ac_tool_prefix}thin_repair; ac_word=$2
@@ -7506,7 +7506,7 @@ fi
 		test -z "$THIN_REPAIR_CMD" && {
 			{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: thin_repair not found in path $PATH" >&5
 $as_echo "$as_me: WARNING: thin_repair not found in path $PATH" >&2;}
-			THIN_REPAIR_CMD=thin_repair
+			THIN_REPAIR_CMD=/usr/sbin/thin_repair
 			THIN_CONFIGURE_WARN=y
 		}
 	fi


