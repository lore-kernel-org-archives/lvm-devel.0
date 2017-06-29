From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:26:58 -0400
Subject: master - vgimportclone.sh: double quote
Message-ID: <201706292026.v5TKQwnQ026552@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=275eeb4631657fcb43d27d6cd309f690869c4e2e
Commit:        275eeb4631657fcb43d27d6cd309f690869c4e2e
Parent:        96a2e0024070ee35d68cf0beeeed283bf74318ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 20:05:42 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

vgimportclone.sh: double quote

---
 scripts/vgimportclone.sh |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index da79591..23181ea 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -1,7 +1,7 @@
 #!/bin/bash
 
 # Copyright (C) 2009 Chris Procter All rights reserved.
-# Copyright (C) 2009-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2017 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -30,7 +30,7 @@ LVM="${LVM_BINARY:-lvm}"
 die() {
     code=$1; shift
     echo "Fatal:" "$@" 1>&2
-    exit $code
+    exit "$code"
 }
 
 "$LVM" version >& /dev/null || die 2 "Could not run lvm binary '$LVM'"
@@ -59,9 +59,8 @@ function getvgname {
 
 function checkvalue {
 ### check return value and error if non zero
-    if [ $1 -ne 0 ]
-    then
-        die $1 "$2, error: $1"
+    if [ "$1" -ne 0 ]; then
+        die "$1" "$2, error: $1"
     fi
 }
 
@@ -86,7 +85,7 @@ function cleanup {
     #set to use old lvm.conf
     LVM_SYSTEM_DIR=${ORIG_LVM_SYS_DIR}
 
-    if [ $KEEP_TMP_LVM_SYSTEM_DIR -eq 1 ]; then
+    if [ "$KEEP_TMP_LVM_SYSTEM_DIR" -eq 1 ]; then
         echo "${SCRIPTNAME}: LVM_SYSTEM_DIR (${TMP_LVM_SYSTEM_DIR}) must be cleaned up manually."
     else
         "$RM" -rf -- "${TMP_LVM_SYSTEM_DIR}"
@@ -200,7 +199,7 @@ for ARG
 do
     if [ -b "$ARG" ]
     then
-        ln -s "$ARG" ${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}
+        ln -s "$ARG" "${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}"
         DISKS="${DISKS} ${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}"
         DEVNO=$((${DEVNO}+1))
     else
@@ -245,7 +244,7 @@ CMD_CONFIG_LINE="devices { \
                    use_lvmetad = 0 \
                  }"
 
-$LVM dumpconfig ${LVM_OPTS} --file ${LVMCONF} --mergedconfig --config "${CMD_CONFIG_LINE}"
+$LVM dumpconfig ${LVM_OPTS} --file "${LVMCONF}" --mergedconfig --config "${CMD_CONFIG_LINE}"
 
 checkvalue $? "Failed to generate ${LVMCONF}"
 # Only keep TMP_LVM_SYSTEM_DIR if it contains something worth keeping
@@ -274,7 +273,7 @@ VGLIST=`${LVM} vgs -o vg_name,vg_exported,vg_missing_pv_count --noheadings --bin
 checkvalue $? "Failed to collect VG information"
 
 while read VGNAME VGEXPORTED VGMISSINGPVCOUNT; do
-    if [ $VGMISSINGPVCOUNT -gt 0 ]; then
+    if [ "$VGMISSINGPVCOUNT" -gt 0 ]; then
         echo "Volume Group ${VGNAME} has unknown PV(s), skipping."
         echo "- Were all associated PV(s) supplied as arguments?"
         continue
@@ -295,7 +294,7 @@ while read VGNAME VGEXPORTED VGMISSINGPVCOUNT; do
 
     NEWVGNAME=`getvgname "${OLDVGS}" "${VGNAME}" "${NEWVG}"`
 
-    "$LVM" vgchange ${LVM_OPTS} ${TEST_OPT} --uuid --config 'global{activation=0}' ${VGNAME}
+    "$LVM" vgchange ${LVM_OPTS} ${TEST_OPT} --uuid --config 'global{activation=0}' "$VGNAME"
     checkvalue $? "Unable to change VG uuid for ${VGNAME}"
 
     ## if the name isn't going to get changed dont even try.
@@ -325,7 +324,7 @@ if [ ${CHANGES_MADE} -eq 1 ]
 then
     # get global/use_lvmetad config and if set also notify lvmetad about changes
     # since we were running LVM commands above with use_lvmetad=0
-    eval $(${LVM} dumpconfig ${LVM_OPTS} global/use_lvmetad)
+    eval "$("$LVM" dumpconfig ${LVM_OPTS} global/use_lvmetad)"
     if [ "$use_lvmetad" = "1" ]
     then
       echo "Notifying lvmetad about changes since it was disabled temporarily."


