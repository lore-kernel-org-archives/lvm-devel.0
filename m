From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Nov 2009 14:32:17 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvmconf.sh scripts/lv ...
Message-ID: <20091127143217.9745.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-27 14:32:16

Modified files:
	.              : WHATS_NEW 
	scripts        : lvmconf.sh 
Added files:
	scripts        : lvmconf_lockingtype2.sh 

Log message:
	Use locking_type 3 (compiled in cluster locking) in lvmconf.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1333&r2=1.1334
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvmconf_lockingtype2.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvmconf.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2009/11/25 20:44:07	1.1333
+++ LVM2/WHATS_NEW	2009/11/27 14:32:16	1.1334
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Use locking_type 3 (compiled in cluster locking) in lvmconf.
   Remove duplicate dm_list macros and functions.
   Log failure type and recognise type 'F' (flush) in dmeventd mirror plugin.
   Extend internal PV/VG/LV/segment status variables from 32-bit to 64-bit.
/cvs/lvm2/LVM2/scripts/lvmconf_lockingtype2.sh,v  -->  standard output
revision 1.1
--- LVM2/scripts/lvmconf_lockingtype2.sh
+++ -	2009-11-27 14:32:17.307148000 +0000
@@ -0,0 +1,259 @@
+#!/bin/sh
+#
+# Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+#
+# This file is part of the lvm2-cluster package.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# Edit an lvm.conf file to adjust various properties
+#
+
+function usage
+{
+    echo "usage: $0 <command>"
+    echo ""
+    echo "Commands:"
+    echo "Enable clvm:  --enable-cluster [--lockinglibdir <dir>] [--lockinglib <lib>]"
+    echo "Disable clvm: --disable-cluster"
+    echo "Set locking library: --lockinglibdir <dir> [--lockinglib <lib>]"
+    echo ""
+    echo "Global options:"
+    echo "Config file location: --file <configfile>"
+    echo ""
+}
+
+
+function parse_args
+{
+    while [ -n "$1" ]; do
+        case $1 in
+            --enable-cluster)
+                LOCKING_TYPE=2
+                shift
+                ;;
+            --disable-cluster)
+                LOCKING_TYPE=1
+                shift
+                ;;
+            --lockinglibdir)
+                if [ -n "$2" ]; then
+                    LOCKINGLIBDIR=$2
+                    shift 2
+                else
+                    usage
+                    exit 1
+                fi
+                ;;
+            --lockinglib)
+                if [ -n "$2" ]; then
+                    LOCKINGLIB=$2
+                    shift 2
+                else
+                    usage
+                    exit 1
+                fi
+                ;;
+            --file)
+                if [ -n "$2" ]; then
+                    CONFIGFILE=$2
+                    shift 2
+                else
+                    usage
+                    exit 1
+                fi
+                ;;
+            *)
+                usage
+                exit 1
+        esac
+    done
+}
+
+function validate_args
+{
+    [ -z "$CONFIGFILE" ] && CONFIGFILE="/etc/lvm/lvm.conf"
+
+    if [ ! -f "$CONFIGFILE" ]
+            then
+            echo "$CONFIGFILE does not exist"
+            exit 10
+    fi
+
+    if [ -z "$LOCKING_TYPE" ] && [ -z "$LOCKINGLIBDIR" ]; then
+        usage
+        exit 1
+    fi
+
+    if [ -n "$LOCKINGLIBDIR" ]; then
+
+        [ -z "$LOCKINGLIB" ] && LOCKINGLIB="liblvm2clusterlock.so"
+            
+        if [ "${LOCKINGLIBDIR:0:1}" != "/" ]
+            then
+            echo "Prefix must be an absolute path name (starting with a /)"
+            exit 12
+        fi
+    
+        if [ ! -f "$LOCKINGLIBDIR/$LOCKINGLIB" ]
+            then
+            echo "$LOCKINGLIBDIR/$LOCKINGLIB does not exist, did you do a \"make install\" ?"
+            exit 11
+        fi
+        
+    fi
+
+    if [ "$LOCKING_TYPE" = "1" ] && [ -n "$LOCKINGLIBDIR" -o -n "$LOCKINGLIB" ]; then
+	echo "Superfluous locking lib parameter, ignoring"
+    fi
+}
+
+umask 0077
+
+parse_args "$@"
+
+validate_args
+
+
+SCRIPTFILE=/etc/lvm/.lvmconf-script.tmp
+TMPFILE=/etc/lvm/.lvmconf-tmp.tmp
+
+
+# Flags so we know which parts of the file we can replace and which need
+# adding. These are return codes from grep, so zero means it IS present!
+have_type=1
+have_dir=1
+have_library=1
+have_global=1
+
+grep -q '^[[:blank:]]*locking_type[[:blank:]]*=' $CONFIGFILE
+have_type=$?
+
+grep -q '^[[:blank:]]*library_dir[[:blank:]]*=' $CONFIGFILE
+have_dir=$?
+
+grep -q '^[[:blank:]]*locking_library[[:blank:]]*=' $CONFIGFILE
+have_library=$?
+
+# Those options are in section "global {" so we must have one if any are present.
+if [ "$have_type" = "0" -o "$have_dir" = "0" -o "$have_library" = "0" ]
+then
+
+    # See if we can find it...
+    grep -q '^[[:blank:]]*global[[:blank:]]*{' $CONFIGFILE
+    have_global=$?
+    
+    if [ "$have_global" = "1" ] 
+	then
+	echo "global keys but no 'global {' found, can't edit file"
+	exit 13
+    fi
+fi
+
+if [ "$LOCKING_TYPE" = "2" ] && [ -z "$LOCKINGLIBDIR" ] && [ "$have_dir" = "1" ]; then
+	echo "no library_dir specified in $CONFIGFILE"
+	exit 16
+fi
+
+# So if we don't have "global {" we need to create one and 
+# populate it
+
+if [ "$have_global" = "1" ]
+then
+    if [ -z "$LOCKING_TYPE" ]; then
+	LOCKING_TYPE=1
+    fi
+    if [ "$LOCKING_TYPE" = "2" ]; then
+        cat $CONFIGFILE - <<EOF > $TMPFILE
+global {
+    # Enable locking for cluster LVM
+    locking_type = $LOCKING_TYPE
+    library_dir = "$LOCKINGLIBDIR"
+    locking_library = "$LOCKINGLIB"
+}
+EOF
+    fi # if we aren't setting cluster locking, we don't need to create a global section
+
+    if [ $? != 0 ]
+    then
+	echo "failed to create temporary config file, $CONFIGFILE not updated"
+	exit 14
+    fi
+else
+    #
+    # We have a "global {" section, so add or replace the
+    # locking entries as appropriate
+    #
+
+    if [ -n "$LOCKING_TYPE" ]; then
+	if [ "$have_type" = "0" ] 
+	then
+	    SEDCMD=" s/^[[:blank:]]*locking_type[[:blank:]]*=.*/\ \ \ \ locking_type = $LOCKING_TYPE/g"
+	else
+	    SEDCMD=" /global[[:blank:]]*{/a\ \ \ \ locking_type = $LOCKING_TYPE"
+	fi
+    fi
+    
+    if [ -n "$LOCKINGLIBDIR" ]; then
+        if [ "$have_dir" = "0" ] 
+            then
+            SEDCMD="${SEDCMD}\ns'^[[:blank:]]*library_dir[[:blank:]]*=.*'\ \ \ \ library_dir = \"$LOCKINGLIBDIR\"'g"
+        else
+            SEDCMD="${SEDCMD}\n/global[[:blank:]]*{/a\ \ \ \ library_dir = \"$LOCKINGLIBDIR\""
+        fi
+
+        if [ "$have_library" = "0" ] 
+            then
+            SEDCMD="${SEDCMD}\ns/^[[:blank:]]*locking_library[[:blank:]]*=.*/\ \ \ \ locking_library = \"$LOCKINGLIB\"/g"
+        else
+            SEDCMD="${SEDCMD}\n/global[[:blank:]]*{/a\ \ \ \ locking_library = \"$LOCKINGLIB\""
+        fi
+    fi
+
+    if [ "$LOCKING_TYPE" = "1" ]; then
+        # if we're not using cluster locking, remove the library dir and locking library name
+        if [ "$have_dir" = "0" ] 
+            then
+            SEDCMD="${SEDCMD}\n/^[[:blank:]]*library_dir[[:blank:]]*=.*/d"
+        fi
+
+        if [ "$have_library" = "0" ] 
+            then
+            SEDCMD="${SEDCMD}\n/^[[:blank:]]*locking_library[[:blank:]]*=.*/d"
+        fi
+    fi
+
+    echo -e $SEDCMD > $SCRIPTFILE
+    sed  <$CONFIGFILE >$TMPFILE -f $SCRIPTFILE
+    if [ $? != 0 ]
+    then
+	echo "sed failed, $CONFIGFILE not updated"
+	exit 15
+    fi
+fi
+
+# Now we have a suitably editted config file in a temp place,
+# backup the original and copy our new one into place.
+
+cp $CONFIGFILE $CONFIGFILE.lvmconfold
+if [ $? != 0 ]
+    then
+    echo "failed to backup old config file, $CONFIGFILE not updated"
+    exit 2
+fi
+
+cp $TMPFILE $CONFIGFILE
+if [ $? != 0 ]
+    then
+    echo "failed to copy new config file into place, check $CONFIGFILE is still OK"
+    exit 3
+fi
+
+rm -f $SCRIPTFILE $TMPFILE
--- LVM2/scripts/lvmconf.sh	2006/09/20 17:36:47	1.4
+++ LVM2/scripts/lvmconf.sh	2009/11/27 14:32:16	1.5
@@ -1,6 +1,6 @@
 #!/bin/sh
 #
-# Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the lvm2-cluster package.
 #
@@ -36,7 +36,7 @@
     while [ -n "$1" ]; do
         case $1 in
             --enable-cluster)
-                LOCKING_TYPE=2
+                LOCKING_TYPE=3
                 shift
                 ;;
             --disable-cluster)
@@ -94,20 +94,18 @@
 
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
@@ -149,7 +147,7 @@
     # See if we can find it...
     grep -q '^[[:blank:]]*global[[:blank:]]*{' $CONFIGFILE
     have_global=$?
-    
+
     if [ "$have_global" = "1" ] 
 	then
 	echo "global keys but no 'global {' found, can't edit file"
@@ -170,13 +168,29 @@
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
@@ -184,7 +198,7 @@
     if [ $? != 0 ]
     then
 	echo "failed to create temporary config file, $CONFIGFILE not updated"
-	exit 14
+	exit 17
     fi
 else
     #
@@ -200,7 +214,7 @@
 	    SEDCMD=" /global[[:blank:]]*{/a\ \ \ \ locking_type = $LOCKING_TYPE"
 	fi
     fi
-    
+
     if [ -n "$LOCKINGLIBDIR" ]; then
         if [ "$have_dir" = "0" ] 
             then
@@ -208,8 +222,10 @@
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
@@ -217,19 +233,6 @@
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


