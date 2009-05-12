From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 12 May 2009 18:47:25 -0400
Subject: [PATCH] vgimportclone: script to import SAN snapshots and clones
Message-ID: <1242168445-30898-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Revised vgimportclone that should be ready for inclussion in the LVM2
tree.  Is installed as 'vgimportclone' and a man page is provided.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
Cc: chris procter <chris-procter@talk21.com>
--
 WHATS_NEW                |    1 +
 man/Makefile.in          |    4 +-
 man/vgimportclone.8.in   |   32 +++++
 scripts/Makefile.in      |    2 +
 scripts/vgimportclone.sh |  292 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 329 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3a656ce..acdee84 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Add vgimportclone and install it and the man page by default.
   Add make install_lvm2 as complement to device-mapper install.
   Reject missing PVs from allocation in toollib.
   Fix PV datalignment for values starting prior to MDA area. (2.02.45)
diff --git a/man/Makefile.in b/man/Makefile.in
index 1406dd9..4fde75b 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -29,8 +29,8 @@ MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
 	lvscan.8 pvchange.8 pvck.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
-	vgimport.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 vgrename.8 \
-	vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN)
+	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN)
 MAN8CLUSTER=clvmd.8
 MAN8DM=dmsetup.8
 MAN5DIR=${mandir}/man5
diff --git a/man/vgimportclone.8.in b/man/vgimportclone.8.in
new file mode 100644
index 0000000..50ee4d7
--- /dev/null
+++ b/man/vgimportclone.8.in
@@ -0,0 +1,32 @@
+.TH VGIMPORTCLONE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc." \" -*- nroff -*-
+.SH NAME
+vgimportclone \- restore hardware snapshot
+.SH SYNOPSIS
+.B vgimportclone
+[\-n VolumeGroupName]
+[\-l LvmConfigFile]
+[\-i]
+[\-h]
+PhysicalVolume [PhysicalVolume...]
+.SH DESCRIPTION
+.B vgimportclone
+renames the VG and changes the associated VG and PV UUIDs.
+.SH OPTIONS
+.TP
+.I \-n VolumeGroupName
+Rename the snapshot VG to this name.
+.TP
+.I \-l LvmConfigFile
+The template for the config that is used during the VG rename and UUID changes.
+.TP
+.I \-i
+Import exported Volume Groups.
+.TP
+.I \-h
+Print help message
+.SH ENVIRONMENT VARIABLES
+.TP
+\fBLVM_BINARY\fP 
+The LVM2 binary to use.
+Defaults to "lvm".
+
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 8a03500..e845cca 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -20,6 +20,8 @@ include $(top_srcdir)/make.tmpl
 install:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm_dump.sh \
 		$(sbindir)/lvmdump
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) vgimportclone.sh \
+		$(sbindir)/vgimportclone
 ifeq ("@FSADM@", "yes")
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) fsadm.sh \
 		$(sbindir)/fsadm
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
new file mode 100755
index 0000000..5c4f9fa
--- /dev/null
+++ b/scripts/vgimportclone.sh
@@ -0,0 +1,292 @@
+#!/bin/sh
+
+# Copyright (C) 2009 Chris Procter All rights reserved.
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+#
+# vgimportclone: This script is used to rename the VG and change the associated
+#                VG and PV UUIDs (primary application being HW snapshot restore)
+
+# following external commands are used throughout the script
+# echo and test are internal in bash at least
+RM=rm
+BASENAME=basename
+MKTEMP=mktemp
+SED=sed
+AWK=awk
+CUT=cut
+TR=tr
+READLINK=readlink
+GREP=grep
+
+# user may override lvm location by setting LVM_BINARY
+LVM="${LVM_BINARY:-lvm}"
+
+die() {
+    code=$1; shift
+    echo "Fatal: $@" 1>&2
+    exit $code
+}
+
+"$LVM" version >& /dev/null || die 2 "Could not run lvm binary '$LVM'"
+
+
+function getvgname {
+### get a unique vg name
+###        $1 = list of exists VGs
+###        $2 = the name we want
+    VGLIST=$1
+    VG=$2
+    NEWVG=$3
+
+    BNAME="${NEWVG:-${VG}}"
+    NAME="${BNAME}"
+    I=0
+
+    while [[ "${VGLIST}" =~ "${NAME}" ]]
+    do
+        I=$(($I+1))
+        NAME="${BNAME}.$I"
+    done
+    echo "${NAME}"
+}
+
+
+function checkvalue {
+### check return value and error if non zero
+    if [ $1 -ne 0 ]
+    then
+        die $1 "$2 value: $1"
+    fi
+}
+
+
+function usage {
+### display usage message
+    echo "${SCRIPTNAME} - Restore LVM data from a hardware snapshot"
+    echo -e "Usage: ${SCRIPTNAME} [options] disk1 [disk2 ...]"
+    echo -e "\t\t-h\t\t- Display this usage message"
+    echo -e "\t\t-i\t\t- Import any exported volume groups found"
+    echo -e "\t\t-n\t\t- Name for the new volume group(s)"
+    echo -e "\t\t-l [path]\t- location of lvm.conf (default ${LVMCONF})"
+    exit 0
+}
+
+
+function cleanup {
+    #set to use old lvm.conf
+    LVM_SYSTEM_DIR=${ORIG_LVM_SYS_DIR}
+
+    if [ ${DEBUG} -eq 0 ]
+    then
+         "$RM" -r -- "${TMP_LVM_SYSTEM_DIR}"
+    fi
+}
+
+SCRIPTNAME=`"$BASENAME" $0`
+
+
+if [ "$UID" != "0" -a "$EUID" != "0" ]
+then
+    die 3 "${SCRIPTNAME} must be run as root."
+fi
+
+SHOW=0
+DISKS=""
+LVMCONF="/etc/lvm/lvm.conf"
+TMP_LVM_SYSTEM_DIR=`"$MKTEMP" -d --tmpdir snap.XXXXXXXX`
+NOVGFLAG=0
+IMPORT=0
+DEBUG=0
+DEVNO=0
+
+if [ -n "${LVM_SYSTEM_DIR}" ]; then
+    export ORIG_LVM_SYS_DIR="${LVM_SYSTEM_DIR}"
+    LVMCONF="${LVM_SYSTEM_DIR}/lvm.conf"
+fi
+
+trap  cleanup 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
+
+#####################################################################
+### Get and check arguments
+#####################################################################
+while [ $# -ne 0 ]
+do
+    case $1 in
+        -d)
+            DEBUG=1
+            exec 2> ./${SCRIPTNAME}.log
+            set -x
+            echo "Using $TMP_LVM_SYSTEM_DIR/lvm.conf"
+            shift
+            ;;
+        -h)
+            usage; shift
+            ;;
+        -i)
+            IMPORT=1; shift
+            ;;
+        -l)
+            LVMCONF="$2"; shift; shift
+            ;;
+        -n)
+            NEWVG="$2"; shift; shift
+            ;;
+        *)    
+            if [ -b "$1" ]
+            then
+                ln -s "$1" ${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}
+                DISKS="${DISKS} ${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}"
+                DEVNO=$((${DEVNO}+1))
+            fi
+            shift
+            ;;
+    esac
+done
+
+
+### check we have suitable values for important variables
+if [ -z "${DISKS}" ]
+then
+    usage
+fi
+
+if [ -n "$NEWVG" ]
+then
+    "${LVM}" vgs $NEWVG >& /dev/null && \
+        die 4 "New VG ($NEWVG) already exists."
+fi
+
+test -f $LVMCONF
+checkvalue $? "Specified config file (${LVMCONF}) does not exist."
+
+#####################################################################
+### Get the existing state so we can use it later
+#####################################################################
+
+OLDVGS=`"${LVM}" vgs -o name --noheadings 2>/dev/null`
+checkvalue $? "Current VG names could not be collected without errors."
+
+#####################################################################
+### Prepare the temporay lvm environment
+#####################################################################
+
+###create filter
+for BLOCK in ${DISKS}
+do
+    FILTER="\"a|^${BLOCK}$|\", ${FILTER}"
+done
+
+export FILTER="filter=[ ${FILTER} \"r|.*|\" ]"
+
+"$AWK" -v DEV=${TMP_LVM_SYSTEM_DIR} -v CACHE=${TMP_LVM_SYSTEM_DIR}/cache \
+                   '/^[[:space:]]*filter/{print ENVIRON["FILTER"];next} \
+                    /^[[:space:]]*scan/{print "scan = [ \"" DEV "\" ]";next} \
+                    /^[[:space:]]*cache_dir/{print "cache_dir = \"" CACHE "\"";next} \
+                    {print $0}' < ${LVMCONF} > ${TMP_LVM_SYSTEM_DIR}/lvm.conf
+
+checkvalue $? "Failed to generate ${TMP_LVM_SYSTEM_DIR}/lvm.conf"
+
+# verify the config contains the filter, scan and cache_dir config keywords
+"$GREP" -q '^[[:space:]]*filter' ${TMP_LVM_SYSTEM_DIR}/lvm.conf || \
+    die 5 "Temporary lvm.conf must contain filter config."
+"$GREP" -q '^[[:space:]]*scan' ${TMP_LVM_SYSTEM_DIR}/lvm.conf || \
+    die 6 "Temporary lvm.conf must contain scan config."
+"$GREP" -q '^[[:space:]]*cache_dir' ${TMP_LVM_SYSTEM_DIR}/lvm.conf || \
+    die 7 "Temporary lvm.conf must contain cache_dir config."
+
+### set to use new lvm.conf
+export LVM_SYSTEM_DIR=${TMP_LVM_SYSTEM_DIR}
+
+
+#####################################################################
+### Change the uuids.
+#####################################################################
+
+PVINFO=`"${LVM}" pvs -o pv_name,vg_name,vg_attr --noheadings --separator : 2>/dev/null | "$SED" -e "s/ //g"`
+checkvalue $? "PV info could not be collected without errors."
+
+# output VG info so each line looks like: name:exported?:disk1,disk2,...
+VGINFO=`echo "${PVINFO}" | \
+    "$AWK" -F : '{{vg[$2]=$1","vg[$2]} \
+    if($3 ~ /^..x/){x[$2]="x"}} \
+    END{for(k in vg){printf("%s:%s:%s\n", k, x[k], vg[k])}}'`
+checkvalue $? "PV info could not be parsed without errors."
+
+for VG in ${VGINFO}
+do
+    VGNAME=`echo "${VG}" | "$CUT" -d: -f1`
+    EXPORTED=`echo "${VG}" | "$CUT" -d: -f2`
+    PVLIST=`echo "${VG}" | "$CUT" -d: -f3- | "$TR" , ' '`
+
+    if [ -z "${VGNAME}" ]
+    then
+        FOLLOWLIST=""
+        for DEV in $PVLIST; do
+            FOLLOW=`"$READLINK" $DEV`
+            FOLLOWLIST="$FOLLOW $FOLLOWLIST"
+        done
+        die 8 "Specified PV(s) ($FOLLOWLIST) don't belong to a VG."
+    fi
+
+    if [ -n "${EXPORTED}" ]
+    then
+        if [ ${IMPORT} -eq 1 ]
+        then
+	    "${LVM}" vgimport "${VGNAME}"
+	    checkvalue $? "Volume Group ${VGNAME} could not be imported."
+        else
+            echo "Volume Group ${VGNAME} exported, skipping."
+            continue
+        fi
+    fi
+
+    ### change the pv uuids
+    if [[ "${PVLIST}" =~ "unknown" ]]
+    then
+        echo "Volume Group ${VGNAME} incomplete, skipping."
+        continue
+    fi
+
+    for BLOCKDEV in ${PVLIST}
+    do
+        "${LVM}" pvchange --uuid ${BLOCKDEV} --config 'global{activation=0}'
+        checkvalue $? "Unable to change PV uuid for ${BLOCKDEV}"
+    done
+
+    NEWVGNAME=`getvgname "${OLDVGS}" "${VGNAME}" "${NEWVG}"`
+
+    "${LVM}" vgchange --uuid "${VGNAME}" --config 'global{activation=0}'
+    checkvalue $? "Unable to change VG uuid for ${VGNAME}"
+
+    ## if the name isn't going to get changed dont even try.
+    if [ "${VGNAME}" != "${NEWVGNAME}" ]
+    then
+        "${LVM}" vgrename "${VGNAME}" "${NEWVGNAME}"
+        checkvalue $? "Unable to rename ${VGNAME} to ${NEWVGNAME}"
+    fi
+
+done
+
+#####################################################################
+### Restore the old environment
+#####################################################################
+### set to use old lvm.conf
+LVM_SYSTEM_DIR=${ORIG_LVM_SYS_DIR}
+
+### update the device cache and make sure all
+### the device nodes we need are straight
+
+"${LVM}" pvscan
+"${LVM}" vgmknodes
+
+exit 0


