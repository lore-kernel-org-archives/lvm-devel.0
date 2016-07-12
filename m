From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 12 Jul 2016 08:01:11 +0000 (UTC)
Subject: master - blkdeactivate: add -m|--mpathoption disablequeueing and use it for blk-availability systemd service and initscript
Message-ID: <20160712080111.7E65960E4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42e76a1920c9ee1ae13a3ca4ba2fdd96cad8fe3f
Commit:        42e76a1920c9ee1ae13a3ca4ba2fdd96cad8fe3f
Parent:        9f7e8f22dc42576875a436dee0034d37f89c468c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 12 09:52:18 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 12 10:01:07 2016 +0200

blkdeactivate: add -m|--mpathoption disablequeueing and use it for blk-availability systemd service and initscript

blkdeactivate -m disablequeueing causes "multipathd disablequeueing maps"
call inside blkdeactivate script before deactivating devices. This
avoids a situation where blkdeactivate may wait for paths to appear if
multipath is set to queueing and there's a stack of other devices and/or
mount points on top of such multipath device.

See also https://bugzilla.redhat.com/show_bug.cgi?id=1344381.
---
 WHATS_NEW_DM                                       |    2 +
 man/blkdeactivate.8.in                             |   12 ++++
 scripts/blk_availability_init_red_hat.in           |    2 +-
 .../blk_availability_systemd_red_hat.service.in    |    2 +-
 scripts/blkdeactivate.sh.in                        |   58 ++++++++++++++++----
 5 files changed, 64 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 40452a1..a1d41b4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.131 -
 ================================
+  Disable queueing on mpath devs in blk-availability systemd service/initscript.
+  Add new -m|--mpathoption disablequeueing to blkdeactivate.
   Automatically group regions with 'create --segments' unless --nogroup.
   Fix resource leak when deleting the first member of a group.
   Allow --bounds with 'create --filemap' for dmstats.
diff --git a/man/blkdeactivate.8.in b/man/blkdeactivate.8.in
index 2eb4c6f..8bb10b5 100644
--- a/man/blkdeactivate.8.in
+++ b/man/blkdeactivate.8.in
@@ -7,6 +7,7 @@ blkdeactivate \(em utility to deactivate block devices
 .RB [ \-e ]
 .RB [ \-h ]
 .RB [ \-l \  \fIlvm_options\fP ]
+.RB [ \-m \  \fImpath_options\fP ]
 .RB [ \-u ]
 .RB [ \-v ]
 .RI [ device ]
@@ -51,6 +52,16 @@ Deactivating Volume Group as a whole takes less time than deactivating each
 Logical Volume separately.
 .RE
 .TP
+.BR \-m ", " \-\-mpathoption \ \fImpath_options\fP
+Comma separated list of device-mapper multipath specific options:
+.RS
+.IP \fIdisablequeueing\fP
+Disable queueing on all multipath devices first before deactivation.
+This avoids a situation where blkdeactivate may end up waiting if
+all paths are unavailable for any underlying device-mapper multipath
+device.
+.RE
+.TP
 .BR \-u ", " \-\-umount
 Unmount a mounted device before trying to deactivate it.
 Without this option used, a device that is mounted is not deactivated.
@@ -90,4 +101,5 @@ of device-mapper devices in case the deactivation fails and force removal.
 .BR lsblk (8),
 .BR lvm (8),
 .BR mdadm (8),
+.BR multipathd (8),
 .BR umount (8)
diff --git a/scripts/blk_availability_init_red_hat.in b/scripts/blk_availability_init_red_hat.in
index 3bf2abf..a84ffe7 100644
--- a/scripts/blk_availability_init_red_hat.in
+++ b/scripts/blk_availability_init_red_hat.in
@@ -33,7 +33,7 @@
 
 sbindir=@sbindir@
 script=blkdeactivate
-options="-u -l wholevg"
+options="-u -l wholevg -m disablequeueing"
 
 LOCK_FILE="/var/lock/subsys/blk-availability"
 
diff --git a/scripts/blk_availability_systemd_red_hat.service.in b/scripts/blk_availability_systemd_red_hat.service.in
index 3506738..cc4c678 100644
--- a/scripts/blk_availability_systemd_red_hat.service.in
+++ b/scripts/blk_availability_systemd_red_hat.service.in
@@ -7,7 +7,7 @@ Conflicts=shutdown.target
 [Service]
 Type=oneshot
 ExecStart=/usr/bin/true
-ExecStop=@sbindir@/blkdeactivate -u -l wholevg
+ExecStop=@sbindir@/blkdeactivate -u -l wholevg -m disablequeueing
 RemainAfterExit=yes
 
 [Install]
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index b4c3237..de74756 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -38,6 +38,7 @@ UMOUNT="/bin/umount"
 DMSETUP="@sbindir@/dmsetup"
 LVM="@sbindir@/lvm"
 MDADM="@sbindir@/mdadm"
+MPATHD="/sbin/multipathd"
 
 if $UMOUNT --help | grep -- "--all-targets" >$DEV_DIR/null; then
 	UMOUNT_OPTS="--all-targets "
@@ -49,6 +50,7 @@ fi
 DMSETUP_OPTS=""
 LVM_OPTS=""
 MDADM_OPTS=""
+MPATHD_OPTS=""
 
 LSBLK="/bin/lsblk -r --noheadings -o TYPE,KNAME,NAME,MOUNTPOINT"
 LSBLK_VARS="local devtype local kname local name local mnt"
@@ -68,6 +70,9 @@ LVM_DO_WHOLE_VG=0
 # Do not retry LV deactivation by default.
 LVM_CONFIG="activation{retry_deactivation=0}"
 
+# Do not disable queueing if set on multipath devices.
+MPATHD_DO_DISABLEQUEUEING=0
+
 #
 # List of device names and/or VGs to be skipped.
 # Device name is the KNAME from lsblk output.
@@ -107,20 +112,23 @@ usage() {
 	echo "      If devices are specified, deactivate only supplied devices and their holders."
 	echo
 	echo "  Options:"
-	echo "    -e | --errors                Show errors reported from tools"
-	echo "    -h | --help                  Show this help message"
-	echo "    -d | --dmoption  DM_OPTIONS  Comma separated DM specific options"
-	echo "    -l | --lvmoption LVM_OPTIONS Comma separated LVM specific options"
-	echo "    -u | --umount                Unmount the device if mounted"
-	echo "    -v | --verbose               Verbose mode (also implies -e)"
+	echo "    -e | --errors                    Show errors reported from tools"
+	echo "    -h | --help                      Show this help message"
+	echo "    -d | --dmoption    DM_OPTIONS    Comma separated DM specific options"
+	echo "    -l | --lvmoption   LVM_OPTIONS   Comma separated LVM specific options"
+	echo "    -m | --mpathoption MPATH_OPTIONS Comma separated DM-multipath specific options"
+	echo "    -u | --umount                    Unmount the device if mounted"
+	echo "    -v | --verbose                   Verbose mode (also implies -e)"
 	echo
 	echo "  Device specific options:"
 	echo "    DM_OPTIONS:"
-	echo "      retry    retry removal several times in case of failure"
-	echo "      force    force device removal"
+	echo "      retry           retry removal several times in case of failure"
+	echo "      force           force device removal"
 	echo "    LVM_OPTIONS:"
-	echo "      retry    retry removal several times in case of failure"
-	echo "      wholevg  deactivate the whole VG when processing an LV"
+	echo "      retry           retry removal several times in case of failure"
+	echo "      wholevg         deactivate the whole VG when processing an LV"
+	echo "    MPATH_OPTIONS:"
+	echo "      disablequeueing disable queueing on all DM-multipath devices first"
 
 	exit
 }
@@ -312,6 +320,11 @@ deactivate_all() {
 
 	echo "Deactivating block devices:"
 
+	test $MPATHD_RUNNING -eq 1 && {
+		echo -n "  [DM]: disabling queueing on all multipath devices... "
+		eval $MPATHD $MPATHD_OPTS disablequeueing maps $ERR | grep '^ok$' >$DEV_DIR/null && echo "done" || echo "failed"
+	}
+
 	if test $# -eq 0; then
 		#######################
 		# Process all devices #
@@ -406,6 +419,20 @@ get_lvmopts() {
 	IFS=$ORIG_IFS
 }
 
+get_mpathopts() {
+	ORIG_IFS=$IFS; IFS=','
+
+	for opt in $1; do
+		case "$opt" in
+			"") ;;
+			"disablequeueing") MPATHD_DO_DISABLEQUEUEING=1 ;;
+			*) echo "$opt: unknown DM-multipath option"
+		esac
+	done
+
+	IFS=$ORIG_IFS
+}
+
 set_env() {
 	if test "$ERRORS" -eq "1"; then
 		unset ERR
@@ -419,6 +446,7 @@ set_env() {
 		DMSETUP_OPTS+="-vvvv"
 		LVM_OPTS+="-vvvv"
 		MDADM_OPTS+="-vv"
+		MPATHD_OPTS+="-v 3"
 	else
 		OUT="1>$DEV_DIR/null"
 	fi
@@ -434,6 +462,15 @@ set_env() {
 	else
 		MDADM_AVAILABLE=0
 	fi
+
+	MPATHD_RUNNING=0
+	test $MPATHD_DO_DISABLEQUEUEING -eq 1 && {
+		if test -f $MPATHD; then
+			if eval $MPATHD show daemon $ERR | grep "running" >$DEVDIR/null; then
+				MPATHD_RUNNING=1
+			fi
+		fi
+	}
 }
 
 while test $# -ne 0; do
@@ -443,6 +480,7 @@ while test $# -ne 0; do
 		"-h"|"--help") usage ;;
 		"-d"|"--dmoption ") get_dmopts "$2" ; shift ;;
 		"-l"|"--lvmoption ") get_lvmopts "$2" ; shift ;;
+		"-m"|"--mpathoption ") get_mpathopts "$2" ; shift ;;
 		"-u"|"--umount") DO_UMOUNT=1 ;;
 		"-v"|"--verbose") VERBOSE=1 ; ERRORS=1 ;;
 		"-vv") VERBOSE=1 ; ERRORS=1 ; set -x ;;


