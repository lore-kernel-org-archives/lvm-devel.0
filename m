From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:23 +0200
Subject: [PATCH 09/16] fsadm: Umount ext2 file system prior resize
In-Reply-To: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
References: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317122130-13790-10-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

ext2 does NOT support online resize, so we should attempt to umount the
file system first.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 man/fsadm.8.in   |  323 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 scripts/fsadm.sh |  141 ++++++++++++++++++++---
 2 files changed, 423 insertions(+), 41 deletions(-)

diff --git a/man/fsadm.8.in b/man/fsadm.8.in
index b7bd0a0..62fbb1a 100644
--- a/man/fsadm.8.in
+++ b/man/fsadm.8.in
@@ -1,24 +1,119 @@
 .TH "FSADM" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 .SH "NAME"
-fsadm \- utility to resize or check filesystem on a device
+fsadm \- utility to manage logical volumes
 .SH SYNOPSIS
 .B fsadm
-.RI [ options ]
+.RI "[ " "OPTIONS" " ] " "COMMAND" " [ " "COMMAND_OPTIONS" " ] "
+.R [ ... ]
+.PP
+.B fsadm
+.RI "[ " "OPTIONS" " ]"
 .B check
+[
+.B --help
+]
 .I device
-.sp
+.PP
 .B fsadm
-.RI [ options ]
+.RI "[ " "OPTIONS" " ]"
 .B resize
+[
+.B --help
+]
+[
+.B size=\fISize\fP
+|
+.B size=+\fISize\fP
+|
+.B size=-\fISize\fP
+]
+[
+.I device...
+]
+.I volume
+.PP
+.B fsadm
+.RI "[ " "OPTIONS" " ]
+.B create
+[
+.B --help
+]
+[
+.B stripesize=\fIStripeSize\fP
+]
+[
+.B name=\fIName\fP
+]
+[
+.B fs=\fIType\fP
+|
+.B fstyp=\fIType\fP
+]
+[
+.B size=\fISize\fP
+]
+[
+.B stripes\fIStripes\fP
+]
+[
+.I device...
+]
+[
+.I pool
+]
+.PP
+.B fsadm
+.RI "[ " "OPTIONS" " ]
+.B list
+[
+.B --help
+]
+[
+.B filesystems
+|
+.B fs
+]
+[
+.B device
+|
+.B dev
+]
+[
+.B pool
+]
+.PP
+.B fsadm
+.RI "[ " "OPTIONS" " ]
+.B add
+[
+.B --help
+]
 .I device
-.RI [ new_size [ BKMGTEP ]]
-.sp
+[
+.I device...
+]
+[
+.I pool
+]
+.PP
+.B fsadm
+.RI "[ " "OPTIONS" " ]
+.B remove
+[
+.B --help
+]
+[
+.B --all
+]
+.I item
+[
+.I item...
+]
+.PP
 .SH DESCRIPTION
 .B fsadm
-utility checks or resizes the filesystem on a device.
-It tries to use the same API for 
-.IR ext2 , ext3 , ext4 , ReiserFS
-and \fIXFS\fP filesystem.
+utility to manage logical volumes and pools (volume groups).
+It tries to use the same API for ext3, ext4 and xfs file system.
 .SH OPTIONS
 .TP
 .BR \-h ", " \-\-help
@@ -39,11 +134,117 @@ Print commands without running them.
 .BR \-y ", " \-\-yes
 Answer "yes" at any prompts.
 .TP
-.I new_size
-Absolute number of filesystem blocks to be in the filesystem,
-or an absolute size using a suffix (in powers of 1024).
-If new_size is not supplied, the whole device is used.
-
+.B \-c ", " \-\-config\fP  \fIpath\fP
+Specify the path to the configuration file. If not provided, default
+location will be used. The default locations are
+.B /etc/fsadm.conf
+and
+.B ~/fsadm.conf
+, but options in the second one will override options in the first one.
+.SH COMMANDS
+.TP
+.B check
+Check the file system on
+.I device
+using fsck.
+.TP
+.B resize
+Change the size of the logical
+.I volume
+and file system on it. You can specify
+.B size=\fP\fISize
+to resize to given
+.IR Size ,
+or
+.B size=+\fP\fISize
+to extend the volume by the given
+.IR Size ,
+or
+.B size=-\fP\fISize
+to shrink the volume by the given
+.IR Size .
+If no
+.I Size
+is provided the volume will be resized to its maximum size.
+You can also specify one or more
+.I devices
+to use for extending the
+.IR volume .
+If the device is not in any pool, it will be added the volume's
+pool prior the resize. Note that some file system (namely
+.BR xfs )
+does not support shrinking. Also some file system does not support online
+resize, it means that it will be unmounted before the resize and then mounted
+back afterwards. It will also happen when you specify
+.BR -e ", " --ext-offline
+for extN file systems, or if you're trying to shrink the file system since none
+of supported file system supports online shrinking. And finally, some file
+systems (namely
+.BR xfs )
+does not support offline resize, it means, that the file system will be mounted
+prior to resize and then unmounted afterwards.
+.TP
+.B create
+Create a new logical volume from the
+.IR pool ,
+optionally with the defined file system. You can specify
+.I Type
+of the file system which will be automatically created on the new logical
+volume. Currently only
+.BR ext3 ", " ext4 " and " xfs
+file systems are supported. You can create striped volume by defining the
+.IR StripeSize .
+In that case, if
+.IR Stripes
+is not defined, then number of provided
+.I devices
+will be used. Either
+.I devices
+or
+.I Stripes
+has to be defined if
+.I StripeSize
+is provided, otherwise
+.B fsadm
+does not have enough information to proceed in creating new logical volume.
+Note that if no pool is specified the default pool will be used.
+.TP
+.B list
+List devices, file systems and pools in your system. You can select to list
+all logical volumes by specifying
+.BR filesystems ,
+or
+.BR fs.
+Or you can select to list all pools in the system by specifying
+.BR pool.
+Or you can also select to list all devices in the system by specifying
+.BR devices ,
+or
+.BR dev ,
+however note that this will not list any DM device.
+Optionally you can specify any combination of the above options to list whatever
+you desire, or you can simply omit the option. In that case it will list
+everything as if all options has been specified.
+.TP
+.B add
+Add one, or more
+.I devices
+into the
+.IR pool .
+If no
+.I pool
+is specified, provided
+.I devices
+will be added into the default pool. Note that, if any device is already part
+of the same, or different pool, it will be skipped.
+.TP
+.B remove
+Remove one, or more logical volumes, devices, or pools defined
+by
+.IR items .
+You can also specify
+.B --all
+to remove all pools corresponding volumes from your system.
 .SH DIAGNOSTICS
 On successful completion, the status code is 0.
 A status code of 2 indicates the operation was interrupted by the user.
@@ -51,14 +252,76 @@ A status code of 3 indicates the requested check operation could not be performe
 because the filesystem is mounted and does not support an online 
 .BR fsck (8).
 A status code of 1 is used for other failures.
-
 .SH EXAMPLES
-Resize the filesystem on logical volume /dev/vg/test to 1000 megabytes.
-If /dev/vg/test contains ext2/ext3/ext4
-filesystem it will be unmounted prior the resize.
-All [y|n] questions will be answered 'y'.
-.sp
-.B fsadm \-e \-y resize /dev/vg/test 1000M
+To
+.B add
+device
+.I /dev/sdb
+into the default pool run this command:
+.PP
+    \fB fsadm add /dev/sdb
+.PP
+You can also add mode devices into another pool called
+.I mypool
+.PP
+    \fB fsadm add /dev/sdc /dev/sdd /dev/sde mypool
+.PP
+To create a 300GB linear logical volume with
+.B ext4
+file system using devices
+.B /dev/sda
+and
+.B /dev/sdb
+you can use the following command:
+.PP
+    \fB fsadm create fs=ext4 size=300G /dev/sda /dev/sdb
+.PP
+Of course, we are assuming that /dev/sda and /dev/sdb does have at least 300GB
+of space when combined, otherwise the volume creation would fail.
+.PP
+Now let's create 500GB striped volume with stripe size of 16KB and
+.B xfs
+file system using four devices. It means that
+.I Stripes
+will be equal to 4, however note that we do not need to define
+.I Stripes
+manually if we are listing devices as follows:
+.PP
+    \fB fsadm create fs=xfs size=500G stripesize=16 /dev/sda /dev/sdb /dev/sdc /dev/sdd
+.PP
+Now, if we assume that we already have at least four devices in the default
+pool, we can achieve the same result by calling:
+.PP
+    \fB fsadm create fs=xfs size=500G stripesize=16 stripes=4
+.PP
+To
+.B shrink
+the
+.B default_pool/lvol001
+logical volume by 10G we can simply call
+.PP
+    \fB fsadm resize size=-10G default_pool/lvol001
+.PP
+Or we can
+.B extend
+it by 1T using more devices which are not in the pool just yet:
+.PP
+    \fB fsadm resize size=+1T default_pool/lvol001 /dev/sde /dev/sdf
+.PP
+To
+.B remove
+the above logical volume we can use the following command:
+.PP
+    \fB fsadm remove default_pool/lvol001
+.PP
+or we can simply remove the whole pool, wiping all logical volumes in it:
+.PP
+    \fB fsadm remove default_pool
+.PP
+Alternatively we can remove all pools in the system by calling:
+.PP
+    \fB fsadm remove --all
+.PP
 .SH ENVIRONMENT VARIABLES
 .TP
 .B TMPDIR
@@ -67,6 +330,22 @@ The temporary directory name for mount points. Defaults to "/tmp".
 .B DM_DEV_DIR
 The device directory name.
 Defaults to "/dev" and must be an absolute path.
+.TP
+.B DEFAULT_POOL
+Default pool that will be used in
+.B fsadm
+command if not pool is specified. It defaults to "default_pool" and can
+also be set in configuration file (see
+.B \-c ", " \-\-config\fP  \fIpath\fP
+).
+.TP
+.B LVOL_PREFIX
+Defines the name of the newly created volume if no
+.B name=
+is provided. Defaults to "lvol" and will be concatenated with the number
+of the volume. It can also be set in configuration file (see
+.B \-c ", " \-\-config\fP  \fIpath\fP
+).
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index abd9c3f..bafafb7 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -94,27 +94,107 @@ MAX_VGS=999
 NL='
 '
 
-tool_usage() {
-	echo "${TOOL}: Utility to resize or check the filesystem on a device"
-	echo
+check_usage() {
 	echo "  ${TOOL} [options] check device"
 	echo "    - Check the filesystem on device using fsck"
 	echo
-	echo "  ${TOOL} [options] resize device [new_size[BKMGTPE]]"
-	echo "    - Change the size of the filesystem on device to new_size"
+}
+
+resize_usage() {
+	echo "  ${TOOL} [options] resize [resize options] [device...] volume"
+	echo "    - Change the size of the logical volume and file system on it"
+	echo
+	echo "  Resize options:"
+	echo "    size=n        Resize the volume to the given size."
+	echo "    size=+n       Extend the volume by the given size."
+	echo "    size=-n       Shrink the volume by the given size."
+	echo "    [device...]   Devices to use when extending the volume. If the"
+	echo "                  device is not in any pool, it is added to the"
+	echo "                  volume's pool prior to the extension."
+	echo "    A suffix K, M, G, T, P, E can be used to define size units."
 	echo
-	echo "  Options:"
-	echo "    -h | --help         Show this help message"
-	echo "    -v | --verbose      Be verbose"
-	echo "    -e | --ext-offline  unmount filesystem before ext2/ext3/ext4 resize"
-	echo "    -f | --force        Bypass sanity checks"
-	echo "    -n | --dry-run      Print commands without running them"
-	echo "    -y | --yes          Answer \"yes\" at any prompts"
+}
+
+create_usage() {
+	echo "  ${TOOL} [options] create [create options] [device...] [pool]"
+	echo "    - Create a new logical volume from the pool"
 	echo
-	echo "  new_size - Absolute number of filesystem blocks to be in the filesystem,"
-	echo "             or an absolute size using a suffix (in powers of 1024)."
-	echo "             If new_size is not supplied, the whole device is used."
+	echo "  Create options:"
+	echo "    stripesize=n     Gives the number of kilobytes for the granularity"
+	echo "                     of stripes (see man 8 fsadm for more information)."
+	echo "                     This is optional and if not given, linear logical"
+	echo "                     volume will be created."
+	echo "    name=n           The name for the new logical volume. Without this"
+	echo "                     option the default names of "lvol#" will be generated"
+	echo "                     where # is internal number of the logical volume"
+	echo "                     The default can be changed by setting LVOL_PREFIX"
+	echo "                     fsadm configuration file."
+	echo "    fstyp=n | fs=n   Gives the file system type to create on the new"
+	echo "                     logical volume. Supported file systems are (ext3,"
+	echo "                     ext4, xfs). This is optional and if not given"
+	echo "                     file system will not be created."
+	echo "    size=n           Gives the size to allocate for the new logical volume"
+	echo "                     A size suffix K, M, G, T, P, E can be used to define"
+	echo "                     units (see man 8 fsadm for more information). This"
+	echo "                     is optional if if not given maximum size will be"
+	echo "                     used."
+	echo "    stripes=n        Gives the number of stripes. This is equal to the"
+	echo "                     number of physical volumes to scatter the logical"
+	echo "                     volume. This is optional and if stripesize is set"
+	echo "                     and multiple devices are provided stripes is"
+	echo "                     determined automatically."
+	echo
+}
+
+list_usage() {
+	echo "  ${TOOL} [options] list [filesystems|fs|devices|dev|pool]"
+	echo "    - List devices, file systems and pools in your system"
+	echo
+	echo "  List options:"
+	echo "    filesystems | fs   List all logical volumes."
+	echo "    devices | dev      List all devices except the ones create by DM."
+	echo "    pool               List all available pools to create new logical"
+	echo "                       volumes from."
+	echo
+}
 
+add_usage() {
+	echo "  ${TOOL} [options] add device [device...] [pool]"
+	echo "    - Add one, or more devices into the defined, or default pool"
+	echo
+}
+
+remove_usage() {
+	echo "  ${TOOL} [options] remove [remove options] item [item...]"
+	echo "    - Remove one, or more logical volumes, devices, or pools defined"
+	echo "      by item"
+	echo
+	echo "  Remove options:"
+	echo "    item   Can be logical volume, mount point, device in the pool"
+	echo "             or name of the pool to remove."
+	echo "    --all    Removes all pools and corresponding logical volumes"
+	echo
+
+}
+
+tool_usage() {
+	echo "${TOOL}: Utility to manage logical volumes"
+	echo
+	check_usage
+	resize_usage
+	create_usage
+	list_usage
+	add_usage
+	remove_usage
+	echo "  Options:"
+	echo "    -h | --help           Show this help message"
+	echo "    -v | --verbose        Be verbose"
+	echo "    -e | --ext-offline    unmount filesystem before ext2/ext3/ext4 resize"
+	echo "    -f | --force          Bypass sanity checks"
+	echo "    -n | --dry-run        Print commands without running them"
+	echo "    -y | --yes            Answer \"yes\" at any prompts"
+	echo "    -c | --config path    Specify the path to the configuration file"
+	echo
 	exit
 }
 
@@ -417,6 +497,11 @@ resize_ext() {
 	decode_size $1 $BLOCKSIZE
 	FSFORCE=$FORCE
 
+	# ext2 does NOT support online resize
+	if [ "$FSTYPE" == "ext2" ]; then
+		EXTOFF=1
+	fi
+
 	detect_mounted
 	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
 		[ "$MOUNTED" ] && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
@@ -562,6 +647,10 @@ resize_lvolume() {
 }
 
 resize() {
+	if [ "$1" == "--help" ]; then
+		resize_usage
+		exit
+	fi
 	local size=
 	devcount=
 
@@ -698,11 +787,14 @@ create() {
 			continue
 		fi
 		case $i in
-			"stripesize"* | "chunksize"*) stripesize=${i##*=} ;;
+			"stripesize"*) stripesize=${i##*=} ;;
 			"name"*) name=${i##*=} ;;
 			"fstyp"* | "fs"*) fstyp=${i##*=} ;;
 			"size"*) size=${i##*=} ;;
 			"stripes"*) stripes=${i##*=} ;;
+			"--help") create_usage
+				  exit
+				  ;;
 			*) if [ -z $vgname ]; then vgname=$i; else
 				error "Wrong option $i. (see: $TOOL --help)"
 			   fi ;;
@@ -868,9 +960,9 @@ remove() {
 		      "(see $TOOL remove --help)."
 	fi
 	# help
-	if [ "$1" == "help" ]; then
-		echo "Usage: $TOOL remove [mount point | dm device | voulume group | device | --all]"
-		exit 0
+	if [ "$1" == "--help" ]; then
+		remove_usage
+		exit
 	elif [ "$1" == "--all" ]; then
 		list="$(LANG=C $LVM vgs -o vg_name --separator ' ' --noheadings --nosuffix --units k 2> /dev/null)"
 	else
@@ -1117,6 +1209,9 @@ list() {
 			"filesystems" | "fs") list_filesystems ;;
 			"devices" | "dev") list_devices ;;
 			"pool") list_pool ;;
+			"--help") list_usage
+				  exit
+				  ;;
 			*) error "Wrong option $i. (see: $TOOL --help)"
 		esac
 	done
@@ -1141,6 +1236,10 @@ detect_volume_group() {
 # Add devices into the group
 ############################
 add() {
+	if [ "$1" == "--help" ]; then
+		add_usage
+		exit
+	fi
 	vg_create=0
 	devcount=0
 	tmp=$(mktemp)
@@ -1192,6 +1291,10 @@ diff_dates() {
 # Check filesystem
 ###################
 check() {
+	if [ "$1" == "--help" ]; then
+		check_usage
+		exit
+	fi
 	detect_fs "$1" || error "Cannot get FSTYPE of \"$VOLUME\""
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
 	if detect_mounted ; then
-- 
1.7.4.4


