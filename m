From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Aug 2019 06:58:45 -0400
Subject: master - make: generate
Message-ID: <201908091058.x79AwjF1031596@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=08396b4bce45fb8311979250623f04ec0ddb628c
Commit:        08396b4bce45fb8311979250623f04ec0ddb628c
Parent:        728435e7d680c95fd21fe496d707d1c77adf7d85
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 9 12:56:28 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 9 12:57:07 2019 +0200

make: generate

Run make generate.
---
 conf/example.conf.in   |   18 +++++++-----
 man/lvconvert.8_pregen |   70 ++++++++++++++++++++++++++----------------------
 2 files changed, 48 insertions(+), 40 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 154f621..91ce5be 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -142,7 +142,7 @@ devices {
 	# 
 	# Example
 	# Accept every block device:
-	# filter = [ "a|.*/|" ]
+	# filter = [ "a|.*|" ]
 	# Reject the cdrom drive:
 	# filter = [ "r|/dev/cdrom|" ]
 	# Work with just loopback devices, e.g. for testing:
@@ -150,10 +150,10 @@ devices {
 	# Accept all loop devices and ide drives except hdc:
 	# filter = [ "a|loop|", "r|/dev/hdc|", "a|/dev/ide|", "r|.*|" ]
 	# Use anchors to be very specific:
-	# filter = [ "a|^/dev/hda8$|", "r|.*/|" ]
+	# filter = [ "a|^/dev/hda8$|", "r|.*|" ]
 	# 
 	# This configuration option has an automatic default value.
-	# filter = [ "a|.*/|" ]
+	# filter = [ "a|.*|" ]
 
 	# Configuration option devices/global_filter.
 	# Limit the block devices that are used by LVM system components.
@@ -163,7 +163,7 @@ devices {
 	# The syntax is the same as devices/filter. Devices rejected by
 	# global_filter are not opened by LVM.
 	# This configuration option has an automatic default value.
-	# global_filter = [ "a|.*/|" ]
+	# global_filter = [ "a|.*|" ]
 
 	# Configuration option devices/types.
 	# List of additional acceptable block device types.
@@ -347,6 +347,12 @@ devices {
 	# Enabling this setting allows the VG to be used as usual even with
 	# uncertain devices.
 	allow_changes_with_duplicate_pvs = 0
+
+	# Configuration option devices/allow_mixed_block_sizes.
+	# Allow PVs in the same VG with different logical block sizes.
+	# When allowed, the user is responsible to ensure that an LV is
+	# using PVs with matching block sizes when necessary.
+	allow_mixed_block_sizes = 0
 }
 
 # Configuration section allocation.
@@ -899,9 +905,6 @@ global {
 	# the error messages.
 	activation = 1
 
-	# Configuration option global/segment_libraries.
-	# This configuration option does not have a default value defined.
-
 	# Configuration option global/proc.
 	# Location of proc filesystem.
 	# This configuration option is advanced.
@@ -1751,7 +1754,6 @@ activation {
 	# additional space for VG metadata. The --metadatasize option overrides
 	# this setting.
 	# This configuration option does not have a default value defined.
-	# This configuration option has an automatic default value.
 
 	# Configuration option metadata/pvmetadataignore.
 	# Ignore metadata areas on a new PV.
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 7252f6f..846ea2d 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -378,6 +378,44 @@ Convert LV to striped.
 .RE
 -
 
+Convert LV to type mirror (also see type raid1),
+.br
+.P
+\fBlvconvert\fP \fB--type\fP \fBmirror\fP \fILV\fP
+.br
+.RS 4
+.ad l
+[ \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP ]
+.ad b
+.br
+.ad l
+[ \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+.ad l
+[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--stripes\fP \fINumber\fP ]
+.ad b
+.br
+.ad l
+[    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
 Convert LV to raid or change raid layout 
 .br
 (a specific raid level must be used, e.g. raid1).
@@ -1636,38 +1674,6 @@ For example, LVM_VG_NAME can generally be substituted for a required VG paramete
 .SH ADVANCED USAGE
 Alternate command forms, advanced command usage, and listing of all valid syntax for completeness.
 .P
-Convert LV to type mirror (also see type raid1), 
-.br
-(also see lvconvert --mirrors).
-.br
-.P
-\fBlvconvert\fP \fB--type\fP \fBmirror\fP \fILV\fP
-.br
-.RS 4
-.ad l
-[ \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP ]
-.ad b
-.br
-.ad l
-[ \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT] ]
-.ad b
-.br
-.ad l
-[ \fB-i\fP|\fB--interval\fP \fINumber\fP ]
-.ad b
-.br
-.ad l
-[    \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP ]
-.ad b
-.br
-[ COMMON_OPTIONS ]
-.RE
-.br
-.RS 4
-[ \fIPV\fP ... ]
-.RE
--
-
 Change the region size of an LV.
 .br
 .P


