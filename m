From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:34:01 -0400
Subject: master - tests: scripts double quote
Message-ID: <201707101234.v6ACY1x9022880@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73bbd5528c2ccc9c5bdc4851e1c0b0ade19705ec
Commit:        73bbd5528c2ccc9c5bdc4851e1c0b0ade19705ec
Parent:        74ef5f07d0940a1ce784d569ce7d0bbeef74db87
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 4 11:55:17 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: scripts double quote

---
 scripts/fsadm.sh         |    6 ++--
 scripts/lvmconf.sh       |   86 +++++++++++++++++++++++-----------------------
 scripts/lvmdump.sh.in    |    6 ++--
 scripts/vgimportclone.sh |   14 ++++----
 test/lib/aux.sh          |   32 ++++++++--------
 test/lib/check.sh        |   12 +++---
 test/lib/lvm-wrapper.sh  |    8 ++--
 7 files changed, 82 insertions(+), 82 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index e08862a..459905f 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -641,14 +641,14 @@ do
 	  "-e"|"--ext-offline") EXTOFF=1 ;;
 	  "-y"|"--yes") YES="-y" ;;
 	  "-l"|"--lvresize") DO_LVRESIZE=1 ;;
-	  "check") CHECK="$2" ; shift ;;
-	  "resize") RESIZE="$2"; NEWSIZE="$3" ; shift 2 ;;
+	  "check") CHECK=$2 ; shift ;;
+	  "resize") RESIZE=$2 ; NEWSIZE=$3 ; shift 2 ;;
 	  *) error "Wrong argument \"$1\". (see: $TOOL --help)"
 	esac
 	shift
 done
 
-test "$YES" = "-y" || YES=
+test "$YES" = "-y" || YES=""
 test "$EXTOFF" -eq 1 || EXTOFF=0
 
 if [ -n "$CHECK" ]; then
diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index cbeb4eb..8579338 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -52,7 +52,7 @@ function usage
 function set_default_use_lvmetad_var
 {
 	eval "$(lvm dumpconfig --type default global/use_lvmetad 2>/dev/null)"
-	if [ "$?" != "0" ]; then
+	if [ "$?" != 0 ]; then
 		USE_LVMETAD=0
 	else
                 USE_LVMETAD=$use_lvmetad
@@ -62,7 +62,7 @@ function set_default_use_lvmetad_var
 function parse_args
 {
     while [ -n "$1" ]; do
-        case $1 in
+        case "$1" in
             --enable-cluster)
                 LOCKING_TYPE=3
                 USE_LVMETAD=0
@@ -155,12 +155,12 @@ function validate_args
 	    exit 18
     fi
 
-    if [ "$HANDLE_SERVICES" = "0" ]; then
-        if [ "$HANDLE_MIRROR_SERVICE" = "1" ]; then
+    if [ "$HANDLE_SERVICES" = 0 ]; then
+        if [ "$HANDLE_MIRROR_SERVICE" = 1 ]; then
             echo "--mirrorservice may be used only with --services"
             exit 19
         fi
-        if [ "$START_STOP_SERVICES" = "1" ]; then
+        if [ "$START_STOP_SERVICES" = 1 ]; then
             echo "--startstopservices may be used only with --services"
             exit 19
         fi
@@ -213,16 +213,16 @@ have_library=1
 have_use_lvmetad=1
 have_global=1
 
-grep -q '^[[:blank:]]*locking_type[[:blank:]]*=' $CONFIGFILE
+grep -q '^[[:blank:]]*locking_type[[:blank:]]*=' "$CONFIGFILE"
 have_type=$?
 
-grep -q '^[[:blank:]]*library_dir[[:blank:]]*=' $CONFIGFILE
+grep -q '^[[:blank:]]*library_dir[[:blank:]]*=' "$CONFIGFILE"
 have_dir=$?
 
-grep -q '^[[:blank:]]*locking_library[[:blank:]]*=' $CONFIGFILE
+grep -q '^[[:blank:]]*locking_library[[:blank:]]*=' "$CONFIGFILE"
 have_library=$?
 
-grep -q '^[[:blank:]]*use_lvmetad[[:blank:]]*=' $CONFIGFILE
+grep -q '^[[:blank:]]*use_lvmetad[[:blank:]]*=' "$CONFIGFILE"
 have_use_lvmetad=$?
 
 # Those options are in section "global {" so we must have one if any are present.
@@ -233,14 +233,14 @@ then
     grep -q '^[[:blank:]]*global[[:blank:]]*{' $CONFIGFILE
     have_global=$?
 
-    if [ "$have_global" = "1" ] 
+    if [ "$have_global" = 1 ] 
 	then
 	echo "global keys but no 'global {' found, can't edit file"
 	exit 13
     fi
 fi
 
-if [ "$LOCKING_TYPE" = "2" ] && [ -z "$LOCKINGLIBDIR" ] && [ "$have_dir" = "1" ]; then
+if [ "$LOCKING_TYPE" = 2 ] && [ -z "$LOCKINGLIBDIR" ] && [ "$have_dir" = 1 ]; then
 	echo "no library_dir specified in $CONFIGFILE"
 	exit 16
 fi
@@ -248,13 +248,13 @@ fi
 # So if we don't have "global {" we need to create one and 
 # populate it
 
-if [ "$have_global" = "1" ]
+if [ "$have_global" = 1 ]
 then
     if [ -z "$LOCKING_TYPE" ]; then
 	LOCKING_TYPE=1
     fi
-    if [ "$LOCKING_TYPE" = "3" ] || [ "$LOCKING_TYPE" = "2" ]; then
-        cat $CONFIGFILE - <<EOF > $TMPFILE
+    if [ "$LOCKING_TYPE" = 3 ] || [ "$LOCKING_TYPE" = 2 ]; then
+        cat "$CONFIGFILE" - <<EOF > "$TMPFILE"
 global {
     # Enable locking for cluster LVM
     locking_type = $LOCKING_TYPE
@@ -268,7 +268,7 @@ EOF
 	    exit 14
         fi
 	if [ -n "$LOCKINGLIB" ]; then
-	    cat - <<EOF >> $TMPFILE
+	    cat - <<EOF >> "$TMPFILE"
     locking_library = "$LOCKINGLIB"
 EOF
             if [ $? != 0 ]
@@ -277,7 +277,7 @@ EOF
 	        exit 16
             fi
 	fi
-	cat - <<EOF >> $TMPFILE
+	cat - <<EOF >> "$TMPFILE"
 }
 EOF
     fi # if we aren't setting cluster locking, we don't need to create a global section
@@ -294,7 +294,7 @@ else
     #
 
     if [ -n "$LOCKING_TYPE" ]; then
-	if [ "$have_type" = "0" ] 
+	if [ "$have_type" = 0 ] 
 	then
 	    SEDCMD=" s/^[[:blank:]]*locking_type[[:blank:]]*=.*/\ \ \ \ locking_type = $LOCKING_TYPE/g"
 	else
@@ -303,7 +303,7 @@ else
     fi
 
     if [ -n "$LOCKINGLIBDIR" ]; then
-        if [ "$have_dir" = "0" ] 
+        if [ "$have_dir" = 0 ] 
             then
             SEDCMD="${SEDCMD}\ns'^[[:blank:]]*library_dir[[:blank:]]*=.*'\ \ \ \ library_dir = \"$LOCKINGLIBDIR\"'g"
         else
@@ -312,7 +312,7 @@ else
     fi
 
     if [ -n "$LOCKINGLIB" ]; then
-        if [ "$have_library" = "0" ]
+        if [ "$have_library" = 0 ]
             then
             SEDCMD="${SEDCMD}\ns/^[[:blank:]]*locking_library[[:blank:]]*=.*/\ \ \ \ locking_library = \"$LOCKINGLIB\"/g"
         else
@@ -320,7 +320,7 @@ else
         fi
     fi
 
-    if [ "$have_use_lvmetad" = "0" ]
+    if [ "$have_use_lvmetad" = 0 ]
     then
         SEDCMD="${SEDCMD}\ns'^[[:blank:]]*use_lvmetad[[:blank:]]*=.*'\ \ \ \ use_lvmetad = $USE_LVMETAD'g"
     else
@@ -356,8 +356,8 @@ fi
 rm -f "$SCRIPTFILE" "$TMPFILE"
 
 function set_service {
-    local type="$1"
-    local action="$2"
+    local type=$1
+    local action=$2
     shift 2
 
     if [ "$type" = "systemd" ]; then
@@ -367,7 +367,7 @@ function set_service {
                 eval "$($SYSTEMCTL_BIN show "$i" -p LoadState 2>/dev/null)"
                 test  "$LoadState" = "loaded" || continue
                 $SYSTEMCTL_BIN enable "$i"
-                if [ "$START_STOP_SERVICES" = "1" ]; then
+                if [ "$START_STOP_SERVICES" = 1 ]; then
                     $SYSTEMCTL_BIN start "$i"
                 fi
             done
@@ -376,28 +376,28 @@ function set_service {
                 unset LoadState
                 eval "$($SYSTEMCTL_BIN show "$i" -p LoadState 2>/dev/null)"
                 test  "$LoadState" = "loaded" || continue
-                $SYSTEMCTL_BIN disable "$i"
-                if [ "$START_STOP_SERVICES" = "1" ]; then
-                    $SYSTEMCTL_BIN stop "$i"
+                "$SYSTEMCTL_BIN" disable "$i"
+                if [ "$START_STOP_SERVICES" = 1 ]; then
+                    "$SYSTEMCTL_BIN" stop "$i"
                 fi
             done
         fi
     elif [ "$type" = "sysv" ]; then
         if [ "$action" = "activate" ]; then
             for i in "$@"; do
-                $CHKCONFIG_BIN --list "$i" > /dev/null || continue
-                $CHKCONFIG_BIN "$i" on
-                if [ "$START_STOP_SERVICES" = "1" ]; then
-                    $SERVICE_BIN "$i" start
+                "$CHKCONFIG_BIN" --list "$i" > /dev/null || continue
+                "$CHKCONFIG_BIN" "$i" on
+                if [ "$START_STOP_SERVICES" = 1 ]; then
+                    "$SERVICE_BIN" "$i" start
                 fi
             done
         elif [ "$action" = "deactivate" ]; then
             for i in "$@"; do
-                $CHKCONFIG_BIN --list "$i" > /dev/null  || continue
-                if [ "$START_STOP_SERVICES" = "1" ]; then
-                    $SERVICE_BIN "$i" stop
+                "$CHKCONFIG_BIN" --list "$i" > /dev/null  || continue
+                if [ "$START_STOP_SERVICES" = 1 ]; then
+                    "$SERVICE_BIN" "$i" stop
                 fi
-                $CHKCONFIG_BIN "$i" off
+                "$CHKCONFIG_BIN" "$i" off
             done
         fi
     fi
@@ -405,7 +405,7 @@ function set_service {
 
 # Start/stop and enable/disable services if needed.
 
-if [ "$HANDLE_SERVICES" == "1" ]; then
+if [ "$HANDLE_SERVICES" = 1 ]; then
 
     SYSTEMCTL_BIN=$(which systemctl 2>/dev/null)
     CHKCONFIG_BIN=$(which chkconfig 2>/dev/null)
@@ -413,40 +413,40 @@ if [ "$HANDLE_SERVICES" == "1" ]; then
 
     # Systemd services
     if [ -n "$SYSTEMCTL_BIN" ]; then
-        if [ "$USE_LVMETAD" = "0" ]; then
+        if [ "$USE_LVMETAD" = 0 ]; then
             set_service systemd deactivate lvm2-lvmetad.service lvm2-lvmetad.socket
         else
             set_service systemd activate lvm2-lvmetad.socket
         fi
 
-        if [ "$LOCKING_TYPE" = "3" ]; then
+        if [ "$LOCKING_TYPE" = 3 ]; then
             set_service systemd activate lvm2-cluster-activation.service
-            if [ "$HANDLE_MIRROR_SERVICE" = "1" ]; then
+            if [ "$HANDLE_MIRROR_SERVICE" = 1 ]; then
                 set_service activate lvm2-cmirrord.service
             fi
         else
             set_service systemd deactivate lvm2-cluster-activation.service
-            if [ "$HANDLE_MIRROR_SERVICE" = "1" ]; then
+            if [ "$HANDLE_MIRROR_SERVICE" = 1 ]; then
                 set_service systemd deactivate lvm2-cmirrord.service
             fi
         fi
 
     # System V init scripts
     elif [ -n "$SERVICE_BIN" ] && [ -n "$CHKCONFIG_BIN" ]; then
-        if [ "$USE_LVMETAD" = "0" ]; then
+        if [ "$USE_LVMETAD" = 0 ]; then
             set_service sysv deactivate lvm2-lvmetad
         else
             set_service sysv activate lvm2-lvmetad
         fi
 
-        if [ "$LOCKING_TYPE" = "3" ]; then
+        if [ "$LOCKING_TYPE" = 3 ]; then
             set_service sysv activate clvmd
-            if [ "$HANDLE_MIRROR_SERVICE" = "1" ]; then
+            if [ "$HANDLE_MIRROR_SERVICE" = 1 ]; then
                 set_service sysv activate cmirrord
             fi
         else
             set_service sysv deactivate clvmd
-            if [ "$HANDLE_MIRROR_SERVICE" = "1" ]; then
+            if [ "$HANDLE_MIRROR_SERVICE" = 1 ]; then
                 set_service sysv deactivate cmirrord
             fi
         fi
diff --git a/scripts/lvmdump.sh.in b/scripts/lvmdump.sh.in
index 4bef7df..24e3956 100644
--- a/scripts/lvmdump.sh.in
+++ b/scripts/lvmdump.sh.in
@@ -100,7 +100,7 @@ done
 
 NOW=$("$DATE" -u +%G%m%d%k%M%S | "$TR" -d ' ')
 if test -n "$userdir"; then
-	dir="$userdir"
+	dir=$userdir
 else
 	dirbase="lvmdump-$HOSTNAME-$NOW"
 	dir="$HOME/$dirbase"
@@ -127,7 +127,7 @@ log() {
 }
 
 warnings() {
-	if test "$UID" != "0" && test "$EUID" != "0"; then
+	if test "$UID" != 0 && test "$EUID" != 0; then
 		myecho "WARNING! Running as non-privileged user, dump is likely incomplete!"
 	elif test "$DMSETUP" = ":"; then
 		myecho "WARNING! Could not run dmsetup, dump is likely incomplete."
@@ -163,7 +163,7 @@ if (( clustered )); then
 
 	{
 	for i in nodes status services; do
-		cap_i=$(echo $i|tr a-z A-Z)
+		cap_i=$(echo "$i"|tr a-z A-Z)
 		echo "$cap_i:"
 		echo "----------------------------------"
 		log "cman_tool $i 2>> \"$log\""
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 783857e..061d0d3 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -25,7 +25,7 @@ READLINK=readlink
 GETOPT=getopt
 
 # user may override lvm location by setting LVM_BINARY
-LVM="${LVM_BINARY:-lvm}"
+LVM=${LVM_BINARY:-lvm}
 
 die() {
     code=$1; shift
@@ -45,7 +45,7 @@ function getvgname {
     NEWVG=$3
 
     BNAME="${NEWVG:-${VG}}"
-    NAME="${BNAME}"
+    NAME=${BNAME}
     I=0
 
     while [[ "${VGLIST}" =~ :${NAME}: ]]
@@ -131,7 +131,7 @@ while true
 do
     case $1 in
         -n|--basevgname)
-            NEWVG="$2"; shift; shift
+            NEWVG=$2; shift; shift
             ;;
         -i|--import)
             IMPORT=1; shift
@@ -230,7 +230,7 @@ do
 done
 export FILTER="filter=[ ${FILTER} \"r|.*|\" ]"
 
-LVMCONF=${TMP_LVM_SYSTEM_DIR}/lvm.conf
+LVMCONF="${TMP_LVM_SYSTEM_DIR}/lvm.conf"
 
 CMD_CONFIG_LINE="devices { \
                    scan = [ \"${TMP_LVM_SYSTEM_DIR}\" ] \
@@ -278,7 +278,7 @@ while read -r VGNAME VGEXPORTED VGMISSINGPVCOUNT; do
     fi
 
     if [ "$VGEXPORTED" = "1" ]; then
-        if [ ${IMPORT} -eq 1 ]; then
+        if [ "${IMPORT}" -eq 1 ]; then
             "$LVM" vgimport ${LVM_OPTS} ${TEST_OPT} "${VGNAME}"
             checkvalue $? "Volume Group ${VGNAME} could not be imported"
         else
@@ -318,12 +318,12 @@ fi
 
 ### update the device cache and make sure all
 ### the device nodes we need are straight
-if [ ${CHANGES_MADE} -eq 1 ]
+if [ "${CHANGES_MADE}" -eq 1 ]
 then
     # get global/use_lvmetad config and if set also notify lvmetad about changes
     # since we were running LVM commands above with use_lvmetad=0
     eval "$("$LVM" dumpconfig ${LVM_OPTS} global/use_lvmetad)"
-    if [ "$use_lvmetad" = "1" ]
+    if [ "$use_lvmetad" = 1 ]
     then
       echo "Notifying lvmetad about changes since it was disabled temporarily."
       echo "(This resolves any WARNING message about restarting lvmetad that appears above.)"
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 13be7c5..d3e1af9 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -22,31 +22,31 @@ expect_failure() {
 }
 
 COROSYNC_CONF="/etc/corosync/corosync.conf"
-COROSYNC_NODE="$(hostname)"
+COROSYNC_NODE=$(hostname)
 create_corosync_conf() {
-	if test -a $COROSYNC_CONF; then
-		if ! grep "created by lvm test suite" $COROSYNC_CONF; then
-			rm $COROSYNC_CONF
+	if test -a "$COROSYNC_CONF"; then
+		if ! grep "created by lvm test suite" "$COROSYNC_CONF"; then
+			rm "$COROSYNC_CONF"
 		else
-			mv $COROSYNC_CONF $COROSYNC_CONF.prelvmtest
+			mv "$COROSYNC_CONF" "$COROSYNC_CONF.prelvmtest"
 		fi
 	fi
 
-	sed -e "s/@LOCAL_NODE@/$COROSYNC_NODE/" lib/test-corosync-conf > $COROSYNC_CONF
+	sed -e "s/@LOCAL_NODE@/$COROSYNC_NODE/" lib/test-corosync-conf > "$COROSYNC_CONF"
 	echo "created new $COROSYNC_CONF"
 }
 
 DLM_CONF="/etc/dlm/dlm.conf"
 create_dlm_conf() {
-	if test -a $DLM_CONF; then
-		if ! grep "created by lvm test suite" $DLM_CONF; then
-			rm $DLM_CONF
+	if test -a "$DLM_CONF"; then
+		if ! grep "created by lvm test suite" "$DLM_CONF"; then
+			rm "$DLM_CONF"
 		else
-			mv $DLM_CONF $DLM_CONF.prelvmtest
+			mv "$DLM_CONF" "$DLM_CONF.prelvmtest"
 		fi
 	fi
 
-	cp lib/test-dlm-conf $DLM_CONF
+	cp lib/test-dlm-conf "$DLM_CONF"
 	echo "created new $DLM_CONF"
 }
 
@@ -81,15 +81,15 @@ prepare_dlm() {
 
 SANLOCK_CONF="/etc/sanlock/sanlock.conf"
 create_sanlock_conf() {
-	if test -a $SANLOCK_CONF; then
-		if ! grep "created by lvm test suite" $SANLOCK_CONF; then
-			rm $SANLOCK_CONF
+	if test -a "$SANLOCK_CONF"; then
+		if ! grep "created by lvm test suite" "$SANLOCK_CONF"; then
+			rm "$SANLOCK_CONF"
 		else
-			mv $SANLOCK_CONF $SANLOCK_CONF.prelvmtest
+			mv "$SANLOCK_CONF" "$SANLOCK_CONF.prelvmtest"
 		fi
 	fi
 
-	cp lib/test-sanlock-conf $SANLOCK_CONF
+	cp lib/test-sanlock-conf "$SANLOCK_CONF"
 	echo "created new $SANLOCK_CONF"
 }
 
diff --git a/test/lib/check.sh b/test/lib/check.sh
index a7653b5..603f334 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -40,7 +40,7 @@ lvdevices() {
 
 mirror_images_redundant() {
 	local vg=$1
-	local lv=$vg/$2
+	local lv="$vg/$2"
 	lvs -a "$vg" -o+devices
 	for i in $(lvdevices "$lv"); do
 		echo "# $i:"
@@ -77,7 +77,7 @@ lv_on() {
 
 	devs=( $(lvdevices "$1/$2" | sort | uniq ) )
 
-	lv_on_diff_ devs[@] "${@}"
+	lv_on_diff_ devs[@] "$@"
 }
 
 # list devices for given LV and all its subdevices
@@ -87,7 +87,7 @@ lv_tree_on() {
 	# Get sorted list of devices
 	devs=( $(get lv_tree_devices "$1" "$2") )
 
-	lv_on_diff_ devs[@] "${@}"
+	lv_on_diff_ devs[@] "$@"
 }
 
 mirror_images_on() {
@@ -112,14 +112,14 @@ mirror_log_on() {
 }
 
 lv_is_contiguous() {
-	local lv=$1/$2
+	local lv="$1/$2"
 	test "$(lvl --segments "$lv" | wc -l)" -eq 1 || \
 		die "LV $lv expected to be contiguous, but is not:" \
 			"$(lvl --segments "$lv")"
 }
 
 lv_is_clung() {
-	local lv=$1/$2
+	local lv="$1/$2"
 	test "$(lvdevices "$lv" | sort | uniq | wc -l)" -eq 1 || \
 		die "LV $lv expected to be clung, but is not:" \
 			"$(lvdevices "$lv" | sort | uniq)"
@@ -188,7 +188,7 @@ in_sync() {
 	local type
 	local snap=""
 	local lvm_name="$1/$2"
-	local ignore_a="$3"
+	local ignore_a=$3
 	local dm_name
 
 	dm_name=$(echo "$lvm_name" | sed s:-:--: | sed s:/:-:)
diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index 129cafe..469154a 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2011-2014 Red Hat, Inc.
+# Copyright (C) 2011-2017 Red Hat, Inc.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -33,9 +33,9 @@ fi
 
 case "$CMD" in
   lvs|pvs|vgs|vgck|vgscan)
-	test "${LVM_DEBUG_LEVEL:-0}" -lt 2 && RUN_DBG= ;;
+	test "${LVM_DEBUG_LEVEL:-0}" -lt 2 && RUN_DBG="" ;;
   pvcreate|pvremove|lvremove|vgcreate|vgremove)
-	test "${LVM_DEBUG_LEVEL:-0}" -lt 1 && RUN_DBG= ;;
+	test "${LVM_DEBUG_LEVEL:-0}" -lt 1 && RUN_DBG="" ;;
 esac
 
 # Capture parallel users of debug.log file
@@ -48,6 +48,6 @@ esac
 if test -n "$abs_top_builddir"; then
     exec $RUN_DBG "$abs_top_builddir/tools/lvm" $CMD "$@"
 else # we are testing the lvm on $PATH
-    PATH=$(echo "$PATH" | sed -e s,[^:]*lvm2-testsuite[^:]*:,,g)
+    PATH=$(echo "$PATH" | sed -e 's,[^:]*lvm2-testsuite[^:]*:,,g')
     exec $RUN_DBG lvm $CMD "$@"
 fi


