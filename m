From: Milan Broz <mbroz@redhat.com>
Date: Fri, 27 Nov 2009 15:01:57 +0100
Subject: [PATCH 1/2] Use locking_type 3 (compiled in cluster locking) in lvmconf.
Message-ID: <1259330518-18390-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 scripts/lvmconf.sh |   53 +++++++++++++++++++++++++++------------------------
 1 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index f5c4313..bf1494b 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -1,6 +1,6 @@
 #!/bin/sh
 #
-# Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the lvm2-cluster package.
 #
@@ -36,7 +36,7 @@ function parse_args
     while [ -n "$1" ]; do
         case $1 in
             --enable-cluster)
-                LOCKING_TYPE=2
+                LOCKING_TYPE=3
                 shift
                 ;;
             --disable-cluster)
@@ -94,20 +94,18 @@ function validate_args
 
     if [ -n "$LOCKINGLIBDIR" ]; then
 
-        [ -z "$LOCKINGLIB" ] && LOCKINGLIB="liblvm2clusterlock.so"
-            
         if [ "${LOCKINGLIBDIR:0:1}" != "/" ]
             then
             echo "Prefix must be an absolute path name (starting with a /)"
             exit 12
         fi
-    
-        if [ ! -f "$LOCKINGLIBDIR/$LOCKINGLIB" ]
+
+        if [ -n "$LOCKINGLIB" ] && [ ! -f "$LOCKINGLIBDIR/$LOCKINGLIB" ]
             then
             echo "$LOCKINGLIBDIR/$LOCKINGLIB does not exist, did you do a \"make install\" ?"
             exit 11
         fi
-        
+
     fi
 
     if [ "$LOCKING_TYPE" = "1" ] && [ -n "$LOCKINGLIBDIR" -o -n "$LOCKINGLIB" ]; then
@@ -149,7 +147,7 @@ then
     # See if we can find it...
     grep -q '^[[:blank:]]*global[[:blank:]]*{' $CONFIGFILE
     have_global=$?
-    
+
     if [ "$have_global" = "1" ] 
 	then
 	echo "global keys but no 'global {' found, can't edit file"
@@ -170,13 +168,29 @@ then
     if [ -z "$LOCKING_TYPE" ]; then
 	LOCKING_TYPE=1
     fi
-    if [ "$LOCKING_TYPE" = "2" ]; then
+    if [ "$LOCKING_TYPE" = "3" ] || [ "$LOCKING_TYPE" = "2" ]; then
         cat $CONFIGFILE - <<EOF > $TMPFILE
 global {
     # Enable locking for cluster LVM
     locking_type = $LOCKING_TYPE
     library_dir = "$LOCKINGLIBDIR"
+EOF
+        if [ $? != 0 ]
+        then
+    	    echo "failed to create temporary config file, $CONFIGFILE not updated"
+	    exit 14
+        fi
+	if [ -n "$LOCKINGLIB" ]; then
+	    cat - <<EOF >> $TMPFILE
     locking_library = "$LOCKINGLIB"
+EOF
+            if [ $? != 0 ]
+            then
+	        echo "failed to create temporary config file, $CONFIGFILE not updated"
+	        exit 16
+            fi
+	fi
+	cat - <<EOF >> $TMPFILE
 }
 EOF
     fi # if we aren't setting cluster locking, we don't need to create a global section
@@ -184,7 +198,7 @@ EOF
     if [ $? != 0 ]
     then
 	echo "failed to create temporary config file, $CONFIGFILE not updated"
-	exit 14
+	exit 17
     fi
 else
     #
@@ -200,7 +214,7 @@ else
 	    SEDCMD=" /global[[:blank:]]*{/a\ \ \ \ locking_type = $LOCKING_TYPE"
 	fi
     fi
-    
+
     if [ -n "$LOCKINGLIBDIR" ]; then
         if [ "$have_dir" = "0" ] 
             then
@@ -208,8 +222,10 @@ else
         else
             SEDCMD="${SEDCMD}\n/global[[:blank:]]*{/a\ \ \ \ library_dir = \"$LOCKINGLIBDIR\""
         fi
+    fi
 
-        if [ "$have_library" = "0" ] 
+    if [ -n "$LOCKINGLIB" ]; then
+        if [ "$have_library" = "0" ]
             then
             SEDCMD="${SEDCMD}\ns/^[[:blank:]]*locking_library[[:blank:]]*=.*/\ \ \ \ locking_library = \"$LOCKINGLIB\"/g"
         else
@@ -217,19 +233,6 @@ else
         fi
     fi
 
-    if [ "$LOCKING_TYPE" = "1" ]; then
-        # if we're not using cluster locking, remove the library dir and locking library name
-        if [ "$have_dir" = "0" ] 
-            then
-            SEDCMD="${SEDCMD}\n/^[[:blank:]]*library_dir[[:blank:]]*=.*/d"
-        fi
-
-        if [ "$have_library" = "0" ] 
-            then
-            SEDCMD="${SEDCMD}\n/^[[:blank:]]*locking_library[[:blank:]]*=.*/d"
-        fi
-    fi
-
     echo -e $SEDCMD > $SCRIPTFILE
     sed  <$CONFIGFILE >$TMPFILE -f $SCRIPTFILE
     if [ $? != 0 ]
-- 
1.6.5.3


