From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:08 -0400
Subject: master - vgimportclone.sh: avoid legacy syntax
Message-ID: <201706292027.v5TKR8l8026577@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=588b12e71d7f050ca14e6f9332e7a0ec6b66a4b8
Commit:        588b12e71d7f050ca14e6f9332e7a0ec6b66a4b8
Parent:        d745593e8929bd2ebf928e897a4b7d549ea46cf1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 20:20:15 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

vgimportclone.sh: avoid legacy syntax

Use $(..) instead of legacy `..`.
---
 scripts/vgimportclone.sh |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index f621f99..26e4c1f 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -92,7 +92,7 @@ function cleanup {
     fi
 }
 
-SCRIPTNAME=`"$BASENAME" $0`
+SCRIPTNAME=$("$BASENAME" "$0")
 
 
 if [ "$UID" != "0" -a "$EUID" != "0" ]
@@ -104,7 +104,7 @@ LVM_OPTS=""
 TEST_OPT=""
 DISKS=""
 # for compatibility: using mktemp -t rather than --tmpdir
-TMP_LVM_SYSTEM_DIR=`"$MKTEMP" -d -t snap.XXXXXXXX`
+TMP_LVM_SYSTEM_DIR=$("$MKTEMP" -d -t snap.XXXXXXXX)
 KEEP_TMP_LVM_SYSTEM_DIR=0
 CHANGES_MADE=0
 IMPORT=0
@@ -122,9 +122,9 @@ trap  cleanup 0 1 2 3 4 5 6 7 8 10 11 12 13 14 15 16 17 18
 #####################################################################
 ### Get and check arguments
 #####################################################################
-OPTIONS=`"$GETOPT" -o n:dhitv \
+OPTIONS=$("$GETOPT" -o n:dhitv \
     -l basevgname:,debug,help,import,quiet,test,verbose,version \
-    -n "${SCRIPTNAME}" -- "$@"`
+    -n "${SCRIPTNAME}" -- "$@")
 [ $? -ne 0 ] && usage
 eval set -- "$OPTIONS"
 
@@ -219,7 +219,7 @@ fi
 ###     :vgname1:vgname2:...:vgnameN:
 #####################################################################
 
-OLDVGS=":`"${LVM}" vgs ${LVM_OPTS} -o name --noheadings --rows --separator : --config 'log{prefix=""}'`:"
+OLDVGS=":$("$LVM" vgs ${LVM_OPTS} -o name --noheadings --rows --separator : --config 'log{prefix=""}'):"
 checkvalue $? "Current VG names could not be collected without errors"
 
 #####################################################################
@@ -255,21 +255,21 @@ export LVM_SYSTEM_DIR=${TMP_LVM_SYSTEM_DIR}
 
 # Check if there are any PVs that don't belong to any VG
 # or even if there are disks which are not PVs at all.
-NOVGDEVLIST=`${LVM} pvs -a -o pv_name --select vg_name="" --noheadings`
+NOVGDEVLIST=$("$LVM" pvs -a -o pv_name --select vg_name="" --noheadings)
 checkvalue $? "Failed to collect information for PV check"
 if [ -n "${NOVGDEVLIST}" ]; then
     FOLLOWLIST=""
     while read PVNAME; do
-        FOLLOW=`$READLINK $PVNAME`
+        FOLLOW=$("$READLINK" "$PVNAME")
         FOLLOWLIST="$FOLLOWLIST $FOLLOW"
-    done <<< "`echo "${NOVGDEVLIST}"`"
+    done <<< "$(echo "$NOVGDEVLIST")"
     die 8 "Specified devices don't belong to a VG:$FOLLOWLIST"
 fi
 
 #####################################################################
 ### Rename the VG(s) and change the VG and PV UUIDs.
 #####################################################################
-VGLIST=`${LVM} vgs -o vg_name,vg_exported,vg_missing_pv_count --noheadings --binary`
+VGLIST=$("$LVM" vgs -o vg_name,vg_exported,vg_missing_pv_count --noheadings --binary)
 checkvalue $? "Failed to collect VG information"
 
 while read VGNAME VGEXPORTED VGMISSINGPVCOUNT; do
@@ -292,7 +292,7 @@ while read VGNAME VGEXPORTED VGMISSINGPVCOUNT; do
     "$LVM" pvchange ${LVM_OPTS} ${TEST_OPT} --uuid --config 'global{activation=0}' --select "vg_name=${VGNAME}"
     checkvalue $? "Unable to change all PV uuids in VG ${VGNAME}"
 
-    NEWVGNAME=`getvgname "${OLDVGS}" "${VGNAME}" "${NEWVG}"`
+    NEWVGNAME=$(getvgname "$OLDVGS" "$VGNAME" "$NEWVG")
 
     "$LVM" vgchange ${LVM_OPTS} ${TEST_OPT} --uuid --config 'global{activation=0}' "$VGNAME"
     checkvalue $? "Unable to change VG uuid for ${VGNAME}"
@@ -305,7 +305,7 @@ while read VGNAME VGEXPORTED VGMISSINGPVCOUNT; do
     fi
 
     CHANGES_MADE=1
-done <<< "`echo "${VGLIST}"`"
+done <<< "$(echo "$VGLIST")"
 
 #####################################################################
 ### Restore the old environment


