From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  6 Oct 2015 13:25:17 +0000 (UTC)
Subject: master - man: fsadm
Message-ID: <20151006132517.2815E60F6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b1cadbd87a0814a46b36b07cfe94eda7baacb28
Commit:        4b1cadbd87a0814a46b36b07cfe94eda7baacb28
Parent:        2506275c3b5ec7db8c76ef7fdb07d4f3083a3684
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 5 12:28:00 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 6 15:21:36 2015 +0200

man: fsadm

---
 man/fsadm.8.in   |   95 ++++++++++++++++++++++++++++++++++++-----------------
 scripts/fsadm.sh |    4 +-
 2 files changed, 66 insertions(+), 33 deletions(-)

diff --git a/man/fsadm.8.in b/man/fsadm.8.in
index 2aecd65..02431c5 100644
--- a/man/fsadm.8.in
+++ b/man/fsadm.8.in
@@ -2,72 +2,105 @@
 .SH "NAME"
 fsadm \(em utility to resize or check filesystem on a device
 .SH SYNOPSIS
+.
+.PD 0
+.ad l
+.HP 5
 .B fsadm
 .RI [ options ]
-.B check
-.I device
-.sp
+.BR check
+.IR device
+.
+.HP
 .B fsadm
 .RI [ options ]
-.B resize
-.I device
-.RI [ new_size [ BKMGTEP ]]
-.sp
+.BR resize
+.IR device
+.RI [ new_size ]
+.PD
+.ad b
+.
 .SH DESCRIPTION
+.
 fsadm utility checks or resizes the filesystem on a device.
-It tries to use the same API for 
-.IR ext2 ", " ext3 ", " ext4 ", " ReiserFS " and " XFS
+It tries to use the same API for
+.BR ext2 ,
+.BR ext3 ,
+.BR ext4 ,
+.BR ReiserFS
+.RB and
+.BR XFS
 filesystem.
+.
 .SH OPTIONS
-.TP
-.BR \-e ", " \-\-ext\-offline
+.
+.HP
+.BR \-e | \-\-ext\-offline
+.br
 Unmount ext2/ext3/ext4 filesystem before doing resize.
-.TP
-.BR \-f ", " \-\-force
+.
+.HP
+.BR \-f | \-\-force
+.br
 Bypass some sanity checks.
-.TP
-.BR \-h ", " \-\-help
+.
+.HP
+.BR \-h | \-\-help
+.br
 Display the help text.
-.TP
-.BR \-n ", " \-\-dry\-run
+.
+.HP
+.BR \-n | \-\-dry\-run
+.br
 Print commands without running them.
-.TP
-.BR \-v ", " \-\-verbose
+.
+.HP
+.BR \-v | \-\-verbose
+.br
 Be more verbose.
-.TP
-.BR \-y ", " \-\-yes
+.
+.HP
+.BR \-y | \-\-yes
+.br
 Answer "yes" at any prompts.
-.TP
-.I new_size
+.
+.HP
+.BR \fInew_size [ B | K | M | G | T | P | E ]
+.br
 Absolute number of filesystem blocks to be in the filesystem,
 or an absolute size using a suffix (in powers of 1024).
 If new_size is not supplied, the whole device is used.
-
+.
 .SH DIAGNOSTICS
+.
 On successful completion, the status code is 0.
 A status code of 2 indicates the operation was interrupted by the user.
 A status code of 3 indicates the requested check operation could not be performed
-because the filesystem is mounted and does not support an online 
+because the filesystem is mounted and does not support an online
 .BR fsck (8).
 A status code of 1 is used for other failures.
-
+.
 .SH EXAMPLES
-Resize the filesystem on logical volume /dev/vg/test to 1000 megabytes.
-If /dev/vg/test contains ext2/ext3/ext4
+.
+Resize the filesystem on logical volume \fI/dev/vg/test\fP to 1000 megabytes.
+If \fI/dev/vg/test\fP contains ext2/ext3/ext4
 filesystem it will be unmounted prior the resize.
 All [y/n] questions will be answered 'y'.
 .sp
 .B fsadm \-e \-y resize /dev/vg/test 1000M
+.
 .SH ENVIRONMENT VARIABLES
+.
 .TP
-.B TMPDIR
-The temporary directory name for mount points. Defaults to "/tmp". 
+.B "TMPDIR   "
+The temporary directory name for mount points. Defaults to "\fI/tmp\fP".
 .TP
 .B DM_DEV_DIR
 The device directory name.
-Defaults to "/dev" and must be an absolute path.
+Defaults to "\fI/dev\fP" and must be an absolute path.
 
 .SH SEE ALSO
+.nh
 .BR lvm (8),
 .BR lvresize (8),
 .BR lvm.conf (5),
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index f4ea796..e1aacd8 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -86,10 +86,10 @@ NL='
 tool_usage() {
 	echo "${TOOL}: Utility to resize or check the filesystem on a device"
 	echo
-	echo "  ${TOOL} [options] check device"
+	echo "  ${TOOL} [options] check <device>"
 	echo "    - Check the filesystem on device using fsck"
 	echo
-	echo "  ${TOOL} [options] resize device [new_size[BKMGTPE]]"
+	echo "  ${TOOL} [options] resize <device> [<new_size>[BKMGTPE]]"
 	echo "    - Change the size of the filesystem on device to new_size"
 	echo
 	echo "  Options:"


