From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 Oct 2015 14:32:55 +0000 (UTC)
Subject: master - vgimportclone: cleanup the script and remove dependency on awk, grep, cut and tr
Message-ID: <20151009143255.49E1360FED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f30ba6178df6c3faac06328f17158f549b9d4f7
Commit:        1f30ba6178df6c3faac06328f17158f549b9d4f7
Parent:        8733a8d89040820f66a99d4d4e8f524ab2497983
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 9 16:26:27 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 9 16:31:02 2015 +0200

vgimportclone: cleanup the script and remove dependency on awk, grep, cut and tr

We can replace the expressions with awk/grep/cut/tr with --select now and
more suitable reporting options and modes. Also, we don't need to check
the temporary lvm.conf generated within vgimportclone script since we're
generating it ourselves now using lvmconfig, not using sed anymore like
it was before (so we can be pretty sure it's correct - we use lvmconfig
now even for generating the lvm.conf itself).
---
 WHATS_NEW                |    1 +
 scripts/vgimportclone.sh |   87 +++++++++++++--------------------------------
 2 files changed, 26 insertions(+), 62 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ac9f6b8..9af759e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Cleanup vgimportclone script and remove dependency on awk, grep, cut and tr.
   Add vg_missing_pv_count report field to report number of missing PVs in a VG.
   Properly identify internal LV holding sanlock locks within lv_role field.
   Add metadata_devices and seg_metadata_le_ranges report fields for raid vols.
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index af8cf5c..d14a170 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -21,11 +21,7 @@
 RM=rm
 BASENAME=basename
 MKTEMP=mktemp
-AWK=awk
-CUT=cut
-TR=tr
 READLINK=readlink
-GREP=grep
 GETOPT=getopt
 
 # user may override lvm location by setting LVM_BINARY
@@ -253,59 +249,37 @@ checkvalue $? "Failed to generate ${LVMCONF}"
 # Only keep TMP_LVM_SYSTEM_DIR if it contains something worth keeping
 [ -n "${DEBUG}" ] && KEEP_TMP_LVM_SYSTEM_DIR=1
 
-# verify the config contains the filter, scan and cache_dir (or cache) config keywords
-"$GREP" -q '^[[:space:]]*filter[[:space:]]*=' ${LVMCONF} || \
-    die 5 "Temporary lvm.conf must contain 'filter' config."
-"$GREP" -q '^[[:space:]]*scan[[:space:]]*=' ${LVMCONF} || \
-    die 6 "Temporary lvm.conf must contain 'scan' config."
-
-# check for either 'cache' or 'cache_dir' config values
-"$GREP" -q '[[:space:]]*cache[[:space:]]*=' ${LVMCONF}
-CACHE_RET=$?
-"$GREP" -q '^[[:space:]]*cache_dir' ${LVMCONF}
-CACHE_DIR_RET=$?
-[ $CACHE_RET -eq 0 -o $CACHE_DIR_RET -eq 0 ] || \
-    die 7 "Temporary lvm.conf must contain 'cache' or 'cache_dir' config."
-
 ### set to use new lvm.conf
 export LVM_SYSTEM_DIR=${TMP_LVM_SYSTEM_DIR}
 
+# Check if there are any PVs that don't belong to any VG
+# or even if there are disks which are not PVs at all.
+NOVGDEVLIST=`${LVM} pvs -a -o pv_name --select vg_name="" --noheadings`
+checkvalue $? "Failed to collect information for PV check"
+if [ -n "${NOVGDEVLIST}" ]; then
+    FOLLOWLIST=""
+    while read PVNAME; do
+        FOLLOW=`$READLINK $PVNAME`
+        FOLLOWLIST="$FOLLOWLIST $FOLLOW"
+    done <<< "`echo "${NOVGDEVLIST}"`"
+    die 8 "Specified devices don't belong to a VG:$FOLLOWLIST"
+fi
 
 #####################################################################
 ### Rename the VG(s) and change the VG and PV UUIDs.
 #####################################################################
+VGLIST=`${LVM} vgs -o vg_name,vg_exported,vg_missing_pv_count --noheadings --binary`
+checkvalue $? "Failed to collect VG information"
 
-PVINFO=`"${LVM}" pvs ${LVM_OPTS} -o pv_name,vg_name,vg_attr --noheadings --separator :`
-checkvalue $? "PV info could not be collected without errors"
-
-# output VG info so each line looks like: name:exported?:disk1,disk2,...
-VGINFO=`echo "${PVINFO}" | \
-    "$AWK" -F : '{{sub(/^[ \t]*/,"")} \
-    {sub(/unknown device/,"unknown_device")} \
-    {vg[$2]=$1","vg[$2]} if($3 ~ /^..x/){x[$2]="x"}} \
-    END{for(k in vg){printf("%s:%s:%s\n", k, x[k], vg[k])}}'`
-checkvalue $? "PV info could not be parsed without errors"
-
-for VG in ${VGINFO}
-do
-    VGNAME=`echo "${VG}" | "$CUT" -d: -f1`
-    EXPORTED=`echo "${VG}" | "$CUT" -d: -f2`
-    PVLIST=`echo "${VG}" | "$CUT" -d: -f3- | "$TR" , ' '`
-
-    if [ -z "${VGNAME}" ]
-    then
-        FOLLOWLIST=""
-        for DEV in $PVLIST; do
-            FOLLOW=`"$READLINK" $DEV`
-            FOLLOWLIST="$FOLLOW $FOLLOWLIST"
-        done
-        die 8 "Specified PV(s) ($FOLLOWLIST) don't belong to a VG."
+while read VGNAME VGEXPORTED VGMISSINGPVCOUNT; do
+    if [ $VGMISSINGPVCOUNT -gt 0 ]; then
+        echo "Volume Group ${VGNAME} has unknown PV(s), skipping."
+        echo "- Were all associated PV(s) supplied as arguments?"
+        continue
     fi
 
-    if [ -n "${EXPORTED}" ]
-    then
-        if [ ${IMPORT} -eq 1 ]
-        then
+    if [ "$VGEXPORTED" = "1" ]; then
+        if [ ${IMPORT} -eq 1 ]; then
             "$LVM" vgimport ${LVM_OPTS} ${TEST_OPT} "${VGNAME}"
             checkvalue $? "Volume Group ${VGNAME} could not be imported"
         else
@@ -314,23 +288,12 @@ do
         fi
     fi
 
-    ### change the pv uuids
-    if [[ "${PVLIST}" =~ "unknown" ]]
-    then
-        echo "Volume Group ${VGNAME} has unknown PV(s), skipping."
-        echo "- Were all associated PV(s) supplied as arguments?"
-        continue
-    fi
-
-    for BLOCKDEV in ${PVLIST}
-    do
-        "$LVM" pvchange ${LVM_OPTS} ${TEST_OPT} --uuid ${BLOCKDEV} --config 'global{activation=0}'
-        checkvalue $? "Unable to change PV uuid for ${BLOCKDEV}"
-    done
+    "$LVM" pvchange ${LVM_OPTS} ${TEST_OPT} --uuid --config 'global{activation=0}' --select "vg_name=${VGNAME}"
+    checkvalue $? "Unable to change all PV uuids in VG ${VG_NAME}"
 
     NEWVGNAME=`getvgname "${OLDVGS}" "${VGNAME}" "${NEWVG}"`
 
-    "$LVM" vgchange ${LVM_OPTS} ${TEST_OPT} --uuid "${VGNAME}" --config 'global{activation=0}'
+    "$LVM" vgchange ${LVM_OPTS} ${TEST_OPT} --uuid --config 'global{activation=0}' ${VGNAME}
     checkvalue $? "Unable to change VG uuid for ${VGNAME}"
 
     ## if the name isn't going to get changed dont even try.
@@ -341,7 +304,7 @@ do
     fi
 
     CHANGES_MADE=1
-done
+done <<< "`echo "${VGLIST}"`"
 
 #####################################################################
 ### Restore the old environment


