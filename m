From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 17 Jun 2009 15:47:01 -0000
Subject: LVM2/scripts vgimportclone.sh
Message-ID: <20090617154701.4068.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-06-17 15:47:01

Modified files:
	scripts        : vgimportclone.sh 

Log message:
	Various vgimportclone fixes:
	- validate the specified device is a PV and that it is in a VG
	- automatically enable DEBUG (-d) if >= 4 -v instances were supplied
	- preserve TMP_LVM_SYSTEM_DIR if it contains an lvm.conf and -d was
	specified
	- fix handling of special-case where PV is listed as "unknown device"
	- more descriptive error when a PV is missing ("unknown device")
	- unset LVM_SYSTEM_DIR if it was not originally set
	- skip final vgscan if no changes were made

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/vgimportclone.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/scripts/vgimportclone.sh	2009/05/14 16:46:13	1.1
+++ LVM2/scripts/vgimportclone.sh	2009/06/17 15:47:01	1.2
@@ -90,7 +90,11 @@
     #set to use old lvm.conf
     LVM_SYSTEM_DIR=${ORIG_LVM_SYS_DIR}
 
-    "$RM" -rf -- "${TMP_LVM_SYSTEM_DIR}"
+    if [ $KEEP_TMP_LVM_SYSTEM_DIR -eq 1 ]; then
+        echo "${SCRIPTNAME}: LVM_SYSTEM_DIR (${TMP_LVM_SYSTEM_DIR}) must be cleaned up manually."
+    else
+        "$RM" -rf -- "${TMP_LVM_SYSTEM_DIR}"
+    fi
 }
 
 SCRIPTNAME=`"$BASENAME" $0`
@@ -106,9 +110,12 @@
 DISKS=""
 # for compatibility: using mktemp -t rather than --tmpdir
 TMP_LVM_SYSTEM_DIR=`"$MKTEMP" -d -t snap.XXXXXXXX`
+KEEP_TMP_LVM_SYSTEM_DIR=0
+CHANGES_MADE=0
 IMPORT=0
 DEBUG=""
 VERBOSE=""
+VERBOSE_COUNT=0
 DEVNO=0
 
 if [ -n "${LVM_SYSTEM_DIR}" ]; then
@@ -144,6 +151,7 @@
             shift
             ;;
         -v|--verbose)
+            let VERBOSE_COUNT=VERBOSE_COUNT+1
             if [ -z "$VERBOSE" ]
             then
                 VERBOSE="-v"
@@ -179,11 +187,28 @@
     esac
 done
 
+# turn on DEBUG (special case associated with -v use)
+if [ -z "$DEBUG" -a $VERBOSE_COUNT -gt 3 ]; then
+    DEBUG="-d"
+    set -x
+fi
+
+# setup LVM_OPTS
+if [ -n "${DEBUG}" -o -n "${VERBOSE}" ]
+then
+    LVM_OPTS="${LVM_OPTS} ${DEBUG} ${VERBOSE}"
+fi
+
 # process remaining arguments (which should be disks)
 for ARG
 do
     if [ -b "$ARG" ]
     then
+        PVS_OUT=`"${LVM}" pvs ${LVM_OPTS} --noheadings -o vg_name "$ARG" 2>/dev/null`
+        checkvalue $? "$ARG is not a PV."
+        PV_VGNAME=$(echo $PVS_OUT | $GREP -v '[[:space:]]+$')
+        [ -z "$PV_VGNAME" ] && die 3 "$ARG is not in a VG."
+
         ln -s "$ARG" ${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}
         DISKS="${DISKS} ${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}"
         DEVNO=$((${DEVNO}+1))
@@ -192,12 +217,6 @@
     fi
 done
 
-# setup LVM_OPTS
-if [ -n "${DEBUG}" -o -n "${VERBOSE}" ]
-then
-    LVM_OPTS="${LVM_OPTS} ${DEBUG} ${VERBOSE}"
-fi
-
 ### check we have suitable values for important variables
 if [ -z "${DISKS}" ]
 then
@@ -233,6 +252,8 @@
      {print $0}' > ${LVMCONF}
 
 checkvalue $? "Failed to generate ${LVMCONF}"
+# Only keep TMP_LVM_SYSTEM_DIR if it contains something worth keeping
+[ -n "${DEBUG}" ] && KEEP_TMP_LVM_SYSTEM_DIR=1
 
 # verify the config contains the filter, scan and cache_dir (or cache) config keywords
 "$GREP" -q '^[[:space:]]*filter[[:space:]]*=' ${LVMCONF} || \
@@ -262,6 +283,7 @@
 # output VG info so each line looks like: name:exported?:disk1,disk2,...
 VGINFO=`echo "${PVINFO}" | \
     "$AWK" -F : '{{sub(/^[[:space:]]*/,"")} \
+    {sub(/unknown device/,"unknown_device")} \
     {vg[$2]=$1","vg[$2]} if($3 ~ /^..x/){x[$2]="x"}} \
     END{for(k in vg){printf("%s:%s:%s\n", k, x[k], vg[k])}}'`
 checkvalue $? "PV info could not be parsed without errors"
@@ -297,7 +319,8 @@
     ### change the pv uuids
     if [[ "${PVLIST}" =~ "unknown" ]]
     then
-        echo "Volume Group ${VGNAME} incomplete, skipping."
+        echo "Volume Group ${VGNAME} has unknown PV(s), skipping."
+        echo "- Were all associated PV(s) supplied as arguments?"
         continue
     fi
 
@@ -319,16 +342,25 @@
         checkvalue $? "Unable to rename ${VGNAME} to ${NEWVGNAME}"
     fi
 
+    CHANGES_MADE=1
 done
 
 #####################################################################
 ### Restore the old environment
 #####################################################################
 ### set to use old lvm.conf
-LVM_SYSTEM_DIR=${ORIG_LVM_SYS_DIR}
+if [ -z "${ORIG_LVM_SYS_DIR}" ]
+then
+    unset LVM_SYSTEM_DIR
+else
+    LVM_SYSTEM_DIR=${ORIG_LVM_SYS_DIR}
+fi
 
 ### update the device cache and make sure all
 ### the device nodes we need are straight
-"$LVM" vgscan ${LVM_OPTS} --mknodes
+if [ ${CHANGES_MADE} -eq 1 ]
+then
+    "$LVM" vgscan ${LVM_OPTS} --mknodes
+fi
 
 exit 0


