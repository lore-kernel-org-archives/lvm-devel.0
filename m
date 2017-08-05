From: zren@suse.com <zren@suse.com>
Date: Sat,  5 Aug 2017 22:22:10 +0800
Subject: [PATCH] lvmconf: add support for enabling/disabling lvmlockd
Message-ID: <20170805142210.20427-1-zren@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Eric Ren <zren@suse.com>

lvmconf is handy when you need to change lvm.conf in script,
like resource agent in HA cluster. This patch add support
for enabling/disabling lvmlockd, and also fix some trivial
issues in the original.

Signed-off-by: Eric Ren <zren@suse.com>
---
 man/lvmconf.8_main |  18 +++++++--
 scripts/lvmconf.sh | 112 ++++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 99 insertions(+), 31 deletions(-)

diff --git a/man/lvmconf.8_main b/man/lvmconf.8_main
index ca66ae6..698c336 100644
--- a/man/lvmconf.8_main
+++ b/man/lvmconf.8_main
@@ -4,8 +4,10 @@
 lvmconf \(em LVM configuration modifier
 .SH "SYNOPSIS"
 .B lvmconf
-.RB [ --disable-cluster ]
 .RB [ --enable-cluster ]
+.RB [ --disable-cluster ]
+.RB [ --enable-lvmlockd ]
+.RB [ --disable-lvmlockd ]
 .RB [ --enable-halvm ]
 .RB [ --disable-halvm ]
 .RB [ --file
@@ -26,13 +28,21 @@ changes in the lvm configuration if needed.
 
 .SH "OPTIONS"
 .TP
+.BR --enable-cluster
+Set \fBlocking_type\fR to the default clustered type on this system.
+Also disable lvmetad use as it is not yet supported in clustered environment.
+.TP
 .BR --disable-cluster
 Set \fBlocking_type\fR to the default non-clustered type. Also reset
 lvmetad use to its default.
 .TP
-.BR --enable-cluster
-Set \fBlocking_type\fR to the default clustered type on this system.
-Also disable lvmetad use as it is not yet supported in clustered environment.
+.BR --enable-lvmlockd
+Set \fBlocking_type=1\fR and \fBuse_lvmlockd=1\fR to use lvmlockd on this system.
+Also enable lvmetad since lvmlockd can work with it.
+.TP
+.BR --disable-lvmlockd
+Set \fBuse_lvmlockd=0\fR to disable lvmlockd, and set \fBlocking_type=1\fR.
+Also reset lvmetad use to its default.
 .TP
 .BR --disable-halvm
 Set \fBlocking_type\fR to the default non-clustered type. Also reset
diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index 8579338..47dda81 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -19,6 +19,9 @@
 # cluster with clvmd and/or locking lib?
 HANDLE_CLUSTER=0
 
+# handle lvmlockd?
+HANDLE_LVMLOCKD=0
+
 # cluster without clvmd?
 HANDLE_HALVM=0
 
@@ -38,6 +41,8 @@ function usage
     echo "Commands:"
     echo "Enable clvm:  --enable-cluster [--lockinglibdir <dir>] [--lockinglib <lib>]"
     echo "Disable clvm: --disable-cluster"
+    echo "Enable lvmlockd:  --enable-lvmlockd"
+    echo "Disable lvmlockd: --disable-lvmlockd"
     echo "Enable halvm: --enable-halvm"
     echo "Disable halvm: --disable-halvm"
     echo "Set locking library: --lockinglibdir <dir> [--lockinglib <lib>]"
@@ -55,7 +60,7 @@ function set_default_use_lvmetad_var
 	if [ "$?" != 0 ]; then
 		USE_LVMETAD=0
 	else
-                USE_LVMETAD=$use_lvmetad
+                USE_LVMETAD=1
 	fi
 }
 
@@ -75,6 +80,20 @@ function parse_args
                 HANDLE_CLUSTER=1
                 shift
                 ;;
+            --enable-lvmlockd)
+                USE_LVMLOCKD=1
+                USE_LVMETAD=1
+                LOCKING_TYPE=1
+                HANDLE_LVMLOCKD=1
+                shift
+                ;;
+            --disable-lvmlockd)
+                USE_LVMLOCKD=0
+                set_default_use_lvmetad_var
+                LOCKING_TYPE=1
+                HANDLE_LVMLOCKD=1
+                shift
+                ;;
             --enable-halvm)
                 LOCKING_TYPE=1
 		USE_LVMETAD=0
@@ -155,6 +174,16 @@ function validate_args
 	    exit 18
     fi
 
+    if [ "$HANDLE_LVMLOCKD" = 1 ] && [ "$HANDLE_CLUSTER" = 1 ]; then
+            echo "lvmlockd and clvmd cannot be used together"
+	    exit 18
+    fi
+
+    if [ "$HANDLE_LVMLOCKD" = 1 ] && [ "$HANDLE_HALVM" = 1 ]; then
+            echo "lvmlockd and HA lvm cannot be used together"
+	    exit 18
+    fi
+
     if [ "$HANDLE_SERVICES" = 0 ]; then
         if [ "$HANDLE_MIRROR_SERVICE" = 1 ]; then
             echo "--mirrorservice may be used only with --services"
@@ -211,6 +240,7 @@ have_type=1
 have_dir=1
 have_library=1
 have_use_lvmetad=1
+have_use_lvmlockd=1
 have_global=1
 
 grep -q '^[[:blank:]]*locking_type[[:blank:]]*=' "$CONFIGFILE"
@@ -225,8 +255,12 @@ have_library=$?
 grep -q '^[[:blank:]]*use_lvmetad[[:blank:]]*=' "$CONFIGFILE"
 have_use_lvmetad=$?
 
+grep -q '^[[:blank:]]*use_lvmlockd[[:blank:]]*=' "$CONFIGFILE"
+have_use_lvmlockd=$?
+
 # Those options are in section "global {" so we must have one if any are present.
-if [ "$have_type" = 0 ] || [ "$have_dir" = 0 ] || [ "$have_library" = 0 ] || [ "$have_use_lvmetad" = 0 ]
+if [ "$have_type" = 0 ] || [ "$have_dir" = 0 ] || [ "$have_library" = 0 ] ||
+    [ "$have_use_lvmetad" = 0 ] || [ "$have_use_lvmlockd" = 0 ]
 then
 
     # See if we can find it...
@@ -253,40 +287,57 @@ then
     if [ -z "$LOCKING_TYPE" ]; then
 	LOCKING_TYPE=1
     fi
-    if [ "$LOCKING_TYPE" = 3 ] || [ "$LOCKING_TYPE" = 2 ]; then
-        cat "$CONFIGFILE" - <<EOF > "$TMPFILE"
+
+    # global begin
+    cat "$CONFIGFILE" - <<EOF > "$TMPFILE"
 global {
-    # Enable locking for cluster LVM
-    locking_type = $LOCKING_TYPE
+EOF
+
+    if [ $? != 0 ]; then
+        echo "failed to create temporary config file, $CONFIGFILE not updated"
+	exit 14
+    fi
+
+    if [ "$LOCKING_TYPE" = 3 ] || [ "$LOCKING_TYPE" = 2 ]; then
+        # Disable lvmetad in cluster
+        USE_LVMETAD=0
+    fi
+
+    if [ -n "$USE_LVMETAD" ]; then
+	cat - <<EOF >> "$TMPFILE"
+    use_lvmetad = $USE_LVMETAD
+EOF
+    fi
+
+    if [ -n "$LOCKINGLIBDIR" ]; then
+	cat - <<EOF >> "$TMPFILE"
     library_dir = "$LOCKINGLIBDIR"
-    # Disable lvmetad in cluster
-    use_lvmetad = 0
 EOF
-        if [ $? != 0 ]
-        then
-    	    echo "failed to create temporary config file, $CONFIGFILE not updated"
-	    exit 14
-        fi
-	if [ -n "$LOCKINGLIB" ]; then
-	    cat - <<EOF >> "$TMPFILE"
+    fi
+
+    if [ -n "$LOCKINGLIB" ]; then
+	cat - <<EOF >> "$TMPFILE"
     locking_library = "$LOCKINGLIB"
 EOF
-            if [ $? != 0 ]
-            then
-	        echo "failed to create temporary config file, $CONFIGFILE not updated"
-	        exit 16
-            fi
-	fi
+    fi
+
+    if [ -n "$LOCKING_TYPE" ]; then
 	cat - <<EOF >> "$TMPFILE"
-}
+    locking_type = $LOCKING_TYPE
 EOF
-    fi # if we aren't setting cluster locking, we don't need to create a global section
+    fi
 
-    if [ $? != 0 ]
-    then
-	echo "failed to create temporary config file, $CONFIGFILE not updated"
-	exit 17
+    if [ -n "$USE_LVMLOCKD" ]; then
+	cat - <<EOF >> "$TMPFILE"
+    use_lvmlockd = $USE_LVMLOCKD
+EOF
     fi
+
+    # global end
+    cat - <<EOF >> "$TMPFILE"
+}
+EOF
+
 else
     #
     # We have a "global {" section, so add or replace the
@@ -327,6 +378,13 @@ else
         SEDCMD="${SEDCMD}\n/global[[:blank:]]*{/a\ \ \ \ use_lvmetad = $USE_LVMETAD"
     fi
 
+    if [ "$have_use_lvmlockd" = 0 ]
+    then
+        SEDCMD="${SEDCMD}\ns'^[[:blank:]]*use_lvmlockd[[:blank:]]*=.*'\ \ \ \ use_lvmlockd = $USE_LVMLOCKD'g"
+    else
+        SEDCMD="${SEDCMD}\n/global[[:blank:]]*{/a\ \ \ \ use_lvmlockd = $USE_LVMLOCKD"
+    fi
+
     echo -e "$SEDCMD" > "$SCRIPTFILE"
     sed  <"$CONFIGFILE" >"$TMPFILE" -f "$SCRIPTFILE"
     if [ $? != 0 ]
-- 
2.10.2


