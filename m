From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 13 May 2009 18:32:24 -0400
Subject: [PATCH v2] vgimportclone: script to import SAN snapshots and clones
Message-ID: <1242253944-502-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Revised vgimportclone that should _hopefully_ be ready for inclussion in
the LVM2 tree.  Is installed as 'vgimportclone' and a man page is provided.

NOTE: this script will need to be adjusted slightly if it is to be
married with older versions of LVM (which use the 'cache' config value
rather than 'cache_dir').

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
Cc: chris procter <chris-procter@talk21.com>
--
 WHATS_NEW                |    1 +
 man/Makefile.in          |    4 +-
 man/lvm.8.in             |    3 +
 man/vgimportclone.8.in   |   56 ++++++++
 scripts/Makefile.in      |    2 +
 scripts/vgimportclone.sh |  326 ++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 390 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7b5d249..5036b60 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Add vgimportclone and install it and the man page by default.
   Force max_lv restriction only for newly created LV.
   Remove unneeded import parameter from lv_create_empty.
   Merge lv_is_displayable and lv_is_visible functions.
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
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 6bad5fc..d541fb5 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -95,6 +95,8 @@ The following commands implement the core LVM functionality.
 .TP
 \fBvgimport\fP \(em Make exported volume groups known to the system.
 .TP
+\fBvgimportclone\fP \(em Rename VG and change associated VG and PV UUIDs.
+.TP
 \fBvgmerge\fP \(em Merge two volume groups.
 .TP
 \fBvgmknodes\fP \(em Recreate volume group directory and logical volume special files
@@ -307,6 +309,7 @@ All tools return a status code of zero on success or non-zero on failure.
 .BR vgdisplay (8),
 .BR vgextend (8),
 .BR vgimport (8),
+.BR vgimportclone (8),
 .BR vgmerge (8),
 .BR vgmknodes (8),
 .BR vgreduce (8),
diff --git a/man/vgimportclone.8.in b/man/vgimportclone.8.in
new file mode 100644
index 0000000..31c862a
--- /dev/null
+++ b/man/vgimportclone.8.in
@@ -0,0 +1,56 @@
+.TH VGIMPORTCLONE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc." \" -*- nroff -*-
+.SH NAME
+vgimportclone \- rename VG and change associated VG and PV UUIDs.
+.SH SYNOPSIS
+.B vgimportclone
+[\-n|\-\-basevgname VolumeGroupName]
+[\-i|\-\-import]
+PhysicalVolume [PhysicalVolume...]
+.SH DESCRIPTION
+.B vgimportclone
+is used to rename the VG associated with the specified PV(s) and change the
+associated VG and PV UUIDs.  These changes avoid duplicate VG(s) and
+PV(s) once the origin and snapshots are active simultaneously.  The primary
+application being HW snapshot restore.
+.SH OPTIONS
+See \fBlvm\fP for common options.
+.TP
+.I \-n|\-\-basevgname VolumeGroupName
+By default the snapshot VG will be renamed to the original name plus a
+numeric suffix to avoid duplicate naming (e.g. 'test_vg' would be renamed
+to 'test_vg.1').  This option will override the base VG name that is
+used for all VG renames.  If a VG already exists with the specified name
+a numeric suffix will be added (like the previous example) to make it unique.
+.TP
+.I \-i|\-\-import
+Import exported Volume Groups.  Otherwise VGs that have been exported
+will not be changed (nor will their associated PVs).
+.SH ENVIRONMENT VARIABLES
+.TP
+\fBLVM_BINARY\fP
+The LVM2 binary to use.
+Defaults to "lvm".
+.SH EXAMPLES
+If origin VG
+.B test_vg 
+has PVs 
+.BR /dev/loop0 " and " /dev/loop1
+and 
+.BR /dev/loop2 " and " /dev/loop3
+are respective snapshot PVs of the origin PVs.
+To rename the VG
+associated with
+.BR /dev/loop2 " and " /dev/loop3
+from
+.B test_vg
+to
+.B test_vg.snap
+(and change associated VG and PV UUIDs):
+.nf
+
+\	vgimportclone --basevgname test_vg.snap /dev/loop2 /dev/loop3
+
+.fi
+.SH SEE ALSO
+.BR lvm (8)
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
index 0000000..7f4af6c
--- /dev/null
+++ b/scripts/vgimportclone.sh
@@ -0,0 +1,326 @@
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
+AWK=awk
+CUT=cut
+TR=tr
+READLINK=readlink
+GREP=grep
+GETOPT=getopt
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
+        die $1 "$2, error: $1"
+    fi
+}
+
+
+function usage {
+### display usage message
+    echo "Usage: ${SCRIPTNAME} [options] disk1 [disk2 ...]"
+    echo "    -n|--basevgname - Base name for the new volume group(s)"
+    echo "    -i|--import     - Import any exported volume group(s)"
+    echo "    -t|--test       - Run in test mode"
+    echo "    --quiet         - Suppress output"
+    echo "    -v|--verbose    - Set verbose level"
+    echo "    -d|--debug      - Set debug level"
+    echo "    --version       - Display version information"
+    echo "    -h|--help       - Display this help message"
+    echo ""
+    exit 1
+}
+
+
+function cleanup {
+    #set to use old lvm.conf
+    LVM_SYSTEM_DIR=${ORIG_LVM_SYS_DIR}
+
+    "$RM" -r -- "${TMP_LVM_SYSTEM_DIR}"
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
+LVM_OPTS=""
+TEST_OPT=""
+DISKS=""
+# for compatibility: using mktemp -t rather than --tmpdir
+TMP_LVM_SYSTEM_DIR=`"$MKTEMP" -d -t snap.XXXXXXXX`
+IMPORT=0
+DEBUG=""
+VERBOSE=""
+DEVNO=0
+
+if [ -n "${LVM_SYSTEM_DIR}" ]; then
+    export ORIG_LVM_SYS_DIR="${LVM_SYSTEM_DIR}"
+fi
+
+trap  cleanup 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
+
+#####################################################################
+### Get and check arguments
+#####################################################################
+OPTIONS=`"$GETOPT" -o n:dhitv \
+    -l basevgname:,debug,help,import,quiet,test,verbose,version \
+    -n "${SCRIPTNAME}" -- "$@"`
+[ $? -ne 0 ] && usage
+eval set -- "$OPTIONS"
+
+while true
+do
+    case $1 in
+        -n|--basevgname)
+            NEWVG="$2"; shift; shift
+            ;;
+        -i|--import)
+            IMPORT=1; shift
+            ;;
+	-t|--test)
+	    TEST_OPT="-t"
+	    shift
+	    ;;
+	--quiet)
+	    LVM_OPTS="--quiet ${LVM_OPTS}"
+	    shift
+	    ;;
+	-v|--verbose)
+	    if [ -z "$VERBOSE" ]
+	    then
+		VERBOSE="-v"
+	    else
+		VERBOSE="${VERBOSE}v"
+	    fi
+	    shift
+	    ;;
+	-d|--debug)
+	    if [ -z "$DEBUG" ]
+	    then
+		DEBUG="-d"
+		set -x
+	    else
+		DEBUG="${DEBUG}d"
+	    fi
+	    shift
+	    ;;
+	--version)
+	    "$LVM" version
+	    shift
+	    exit 0
+	    ;;
+        -h|--help)
+            usage; shift
+            ;;
+	--)
+	    shift; break
+	    ;;
+        *)
+	    usage
+	    ;;
+    esac
+done
+
+# process remaining arguments (which should be disks)
+for ARG
+do
+    if [ -b "$ARG" ]
+    then
+        ln -s "$ARG" ${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}
+        DISKS="${DISKS} ${TMP_LVM_SYSTEM_DIR}/vgimport${DEVNO}"
+        DEVNO=$((${DEVNO}+1))
+    else
+	die 3 "$ARG is not a block device."
+    fi
+done
+
+# setup LVM_OPTS
+if [ -n "${DEBUG}" -o -n "${VERBOSE}" ]
+then
+    LVM_OPTS="${LVM_OPTS} ${DEBUG} ${VERBOSE}"
+fi
+
+### check we have suitable values for important variables
+if [ -z "${DISKS}" ]
+then
+    usage
+fi
+
+#####################################################################
+### Get the existing state so we can use it later
+#####################################################################
+
+OLDVGS=`"${LVM}" vgs ${LVM_OPTS} -o name --noheadings 2>/dev/null`
+checkvalue $? "Current VG names could not be collected without errors"
+
+#####################################################################
+### Prepare the temporary lvm environment
+#####################################################################
+
+for BLOCK in ${DISKS}
+do
+    FILTER="\"a|^${BLOCK}$|\", ${FILTER}"
+done
+export FILTER="filter=[ ${FILTER} \"r|.*|\" ]"
+
+LVMCONF=${TMP_LVM_SYSTEM_DIR}/lvm.conf
+
+"$LVM" dumpconfig ${LVM_OPTS} | \
+"$AWK" -v DEV=${TMP_LVM_SYSTEM_DIR} -v CACHE=${TMP_LVM_SYSTEM_DIR}/cache \
+                   '/^[[:space:]]*filter/{print ENVIRON["FILTER"];next} \
+                    /^[[:space:]]*scan/{print "scan = [ \"" DEV "\" ]";next} \
+                    /^[[:space:]]*cache_dir/{print "cache_dir = \"" CACHE "\"";next} \
+                    {print $0}' > ${LVMCONF}
+
+checkvalue $? "Failed to generate ${LVMCONF}"
+
+# verify the config contains the filter, scan and cache_dir config keywords
+"$GREP" -q '^[[:space:]]*filter' ${LVMCONF} || \
+    die 5 "Temporary lvm.conf must contain filter config."
+"$GREP" -q '^[[:space:]]*scan' ${LVMCONF} || \
+    die 6 "Temporary lvm.conf must contain scan config."
+"$GREP" -q '^[[:space:]]*cache_dir' ${LVMCONF} || \
+    die 7 "Temporary lvm.conf must contain cache_dir config."
+
+### set to use new lvm.conf
+export LVM_SYSTEM_DIR=${TMP_LVM_SYSTEM_DIR}
+
+
+#####################################################################
+### Rename the VG(s) and change the VG and PV UUIDs.
+#####################################################################
+
+PVINFO=`"${LVM}" pvs ${LVM_OPTS} -o pv_name,vg_name,vg_attr --noheadings --separator : 2>/dev/null`
+checkvalue $? "PV info could not be collected without errors"
+
+# output VG info so each line looks like: name:exported?:disk1,disk2,...
+VGINFO=`echo "${PVINFO}" | \
+    "$AWK" -F : '{{sub(/^[[:space:]]*/,"")} \
+    {vg[$2]=$1","vg[$2]} if($3 ~ /^..x/){x[$2]="x"}} \
+    END{for(k in vg){printf("%s:%s:%s\n", k, x[k], vg[k])}}'`
+checkvalue $? "PV info could not be parsed without errors"
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
+	    "$LVM" vgimport ${LVM_OPTS} ${TEST_OPT} "${VGNAME}"
+	    checkvalue $? "Volume Group ${VGNAME} could not be imported"
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
+        "$LVM" pvchange ${LVM_OPTS} ${TEST_OPT} --uuid ${BLOCKDEV} --config 'global{activation=0}'
+        checkvalue $? "Unable to change PV uuid for ${BLOCKDEV}"
+    done
+
+    NEWVGNAME=`getvgname "${OLDVGS}" "${VGNAME}" "${NEWVG}"`
+
+    "$LVM" vgchange ${LVM_OPTS} ${TEST_OPT} --uuid "${VGNAME}" --config 'global{activation=0}'
+    checkvalue $? "Unable to change VG uuid for ${VGNAME}"
+
+    ## if the name isn't going to get changed dont even try.
+    if [ "${VGNAME}" != "${NEWVGNAME}" ]
+    then
+        "$LVM" vgrename ${LVM_OPTS} ${TEST_OPT} "${VGNAME}" "${NEWVGNAME}"
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
+"$LVM" vgscan ${LVM_OPTS} --mknodes
+
+exit 0


