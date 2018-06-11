From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Jun 2018 16:27:52 -0400
Subject: master - build: make generate
Message-ID: <201806112027.w5BKRqV2029985@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c2f7f083cc518b11e657b294f42e38a688404e1
Commit:        5c2f7f083cc518b11e657b294f42e38a688404e1
Parent:        2a307ce33c515268763c714275bd4a85bf9fd0fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 8 22:16:00 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 11 22:25:42 2018 +0200

build: make generate

---
 conf/example.conf.in        |   43 ++++---------------------------------------
 man/lvchange.8_pregen       |   14 ++++++++++++++
 man/lvconvert.8_pregen      |   14 ++++++++++++++
 man/lvcreate.8_pregen       |   14 ++++++++++++++
 man/lvdisplay.8_pregen      |   10 ++++++++++
 man/lvextend.8_pregen       |   14 ++++++++++++++
 man/lvm-fullreport.8_pregen |    8 ++++----
 man/lvm-lvpoll.8_pregen     |   10 ++++++++++
 man/lvmconfig.8_pregen      |   10 ++++++++++
 man/lvmdiskscan.8_pregen    |   10 ++++++++++
 man/lvreduce.8_pregen       |   10 ++++++++++
 man/lvremove.8_pregen       |   10 ++++++++++
 man/lvrename.8_pregen       |   10 ++++++++++
 man/lvresize.8_pregen       |   14 ++++++++++++++
 man/lvs.8_pregen            |    8 ++++----
 man/lvscan.8_pregen         |   10 ++++++++++
 man/pvchange.8_pregen       |   10 ++++++++++
 man/pvck.8_pregen           |   10 ++++++++++
 man/pvcreate.8_pregen       |   10 ++++++++++
 man/pvdisplay.8_pregen      |   10 ++++++++++
 man/pvmove.8_pregen         |   10 ++++++++++
 man/pvremove.8_pregen       |   10 ++++++++++
 man/pvresize.8_pregen       |   10 ++++++++++
 man/pvs.8_pregen            |    8 ++++----
 man/pvscan.8_pregen         |   10 ++++++++++
 man/vgcfgbackup.8_pregen    |   10 ++++++++++
 man/vgcfgrestore.8_pregen   |   14 ++++++++++++++
 man/vgchange.8_pregen       |   29 ++++++++++++++---------------
 man/vgck.8_pregen           |   10 ++++++++++
 man/vgconvert.8_pregen      |   10 ++++++++++
 man/vgcreate.8_pregen       |   17 ++++++++++++-----
 man/vgdisplay.8_pregen      |   10 ++++++++++
 man/vgexport.8_pregen       |   10 ++++++++++
 man/vgextend.8_pregen       |   10 ++++++++++
 man/vgimport.8_pregen       |   10 ++++++++++
 man/vgimportclone.8_pregen  |   10 ++++++++++
 man/vgmerge.8_pregen        |   10 ++++++++++
 man/vgmknodes.8_pregen      |   10 ++++++++++
 man/vgreduce.8_pregen       |   14 ++++++++++++++
 man/vgremove.8_pregen       |   10 ++++++++++
 man/vgrename.8_pregen       |   10 ++++++++++
 man/vgs.8_pregen            |    8 ++++----
 man/vgscan.8_pregen         |   10 ++++++++++
 man/vgsplit.8_pregen        |   20 ++++++++++----------
 44 files changed, 444 insertions(+), 85 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 4c62aad..97daab2 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -728,34 +728,7 @@ global {
 	etc = "@CONFDIR@"
 
 	# Configuration option global/locking_type.
-	# Type of locking to use.
-	# 
-	# Accepted values:
-	#   0
-	#     Turns off locking. Warning: this risks metadata corruption if
-	#     commands run concurrently.
-	#   1
-	#     LVM uses local file-based locking, the standard mode.
-	#   2
-	#     LVM uses the external shared library locking_library.
-	#   3
-	#     LVM uses built-in clustered locking with clvmd.
-	#     This is incompatible with lvmetad. If use_lvmetad is enabled,
-	#     LVM prints a warning and disables lvmetad use.
-	#   4
-	#     LVM uses read-only locking which forbids any operations that
-	#     might change metadata.
-	#   5
-	#     Offers dummy locking for tools that do not need any locks.
-	#     You should not need to set this directly; the tools will select
-	#     when to use it instead of the configured locking_type.
-	#     Do not use lvmetad or the kernel device-mapper driver with this
-	#     locking type. It is used by the --readonly option that offers
-	#     read-only access to Volume Group metadata that cannot be locked
-	#     safely because it belongs to an inaccessible domain and might be
-	#     in use, for example a virtual machine image or a disk that is
-	#     shared by a clustered machine.
-	# 
+	# This setting is no longer used.
 	locking_type = 1
 
 	# Configuration option global/wait_for_locks.
@@ -763,19 +736,11 @@ global {
 	wait_for_locks = 1
 
 	# Configuration option global/fallback_to_clustered_locking.
-	# Attempt to use built-in cluster locking if locking_type 2 fails.
-	# If using external locking (type 2) and initialisation fails, with
-	# this enabled, an attempt will be made to use the built-in clustered
-	# locking. Disable this if using a customised locking_library.
+	# This setting is no longer used.
 	fallback_to_clustered_locking = 1
 
 	# Configuration option global/fallback_to_local_locking.
-	# Use locking_type 1 (local) if locking_type 2 or 3 fail.
-	# If an attempt to initialise type 2 or type 3 locking failed, perhaps
-	# because cluster components such as clvmd are not running, with this
-	# enabled, an attempt will be made to use local file-based locking
-	# (type 1). If this succeeds, only commands against local VGs will
-	# proceed. VGs marked as clustered will be ignored.
+	# This setting is no longer used.
 	fallback_to_local_locking = 1
 
 	# Configuration option global/locking_dir.
@@ -799,7 +764,7 @@ global {
 	# This configuration option does not have a default value defined.
 
 	# Configuration option global/locking_library.
-	# The external locking library to use for locking_type 2.
+	# This setting is no longer used.
 	# This configuration option has an automatic default value.
 	# locking_library = "liblvm2clusterlock.so"
 
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 26a6297..8f9783a 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -133,6 +133,10 @@ lvchange - Change the attributes of logical volume(s)
 .ad b
 .br
 .ad l
+    \fB--nolocking\fP
+.ad b
+.br
+.ad l
     \fB--noudevsync\fP
 .ad b
 .br
@@ -576,6 +580,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -876,6 +884,12 @@ See \fBdmeventd\fP(8) for more information.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 91691a3..c9df4da 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -119,6 +119,10 @@ lvconvert - Change logical volume layout
 .ad b
 .br
 .ad l
+    \fB--nolocking\fP
+.ad b
+.br
+.ad l
     \fB--noudevsync\fP
 .ad b
 .br
@@ -903,6 +907,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -1177,6 +1185,12 @@ generated, where # is a number generated by LVM.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 9dcb33f..b6483b5 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -143,6 +143,10 @@ lvcreate - Create a logical volume
 .ad b
 .br
 .ad l
+    \fB--nolocking\fP
+.ad b
+.br
+.ad l
     \fB--nosync\fP
 .ad b
 .br
@@ -916,6 +920,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -1254,6 +1262,12 @@ generated, where # is a number generated by LVM.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--nosync\fP
 .br
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 33e4f5d..6211a47 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -170,6 +170,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -321,6 +325,12 @@ Useful if grepping the output.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--nosuffix\fP
 .br
 Suppress the suffix on output sizes. Use with --units
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 130672e..b29f508 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -63,6 +63,10 @@ lvextend - Add space to a logical volume
 .ad b
 .br
 .ad l
+    \fB--nolocking\fP
+.ad b
+.br
+.ad l
     \fB--nosync\fP
 .ad b
 .br
@@ -324,6 +328,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -455,6 +463,12 @@ this option.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--nosync\fP
 .br
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 3fb00b1..4a8d7b3 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -72,10 +72,6 @@ if information changes between commands.
 .ad b
 .br
 .ad l
-[    \fB--nolocking\fP ]
-.ad b
-.br
-.ad l
 [    \fB--nosuffix\fP ]
 .ad b
 .br
@@ -170,6 +166,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 4591a28..1f4c129 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -84,6 +84,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -169,6 +173,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP
 .br
 The command to perform from lvmpolld.
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index b47d589..0db2dd7 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -153,6 +153,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -281,6 +285,12 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index 8b26d95..8eb57bf 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -79,6 +79,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -144,6 +148,12 @@ Only report PVs.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 3aa4b5a..7acc042 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -110,6 +110,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -214,6 +218,12 @@ this option.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index 88d0501..c835672 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -114,6 +114,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -195,6 +199,12 @@ metadata/record_lvs_history is enabled.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 69711e0..8d2f9b3 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -89,6 +89,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -155,6 +159,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 8df157a..13246f5 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -59,6 +59,10 @@ lvresize - Resize a logical volume
 .ad b
 .br
 .ad l
+    \fB--nolocking\fP
+.ad b
+.br
+.ad l
     \fB--nosync\fP
 .ad b
 .br
@@ -272,6 +276,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -397,6 +405,12 @@ this option.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--nosync\fP
 .br
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index c6303bb..b5128f9 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -76,10 +76,6 @@ lvs produces formatted output about LVs.
 .ad b
 .br
 .ad l
-[    \fB--nolocking\fP ]
-.ad b
-.br
-.ad l
 [    \fB--nosuffix\fP ]
 .ad b
 .br
@@ -174,6 +170,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index e9d90ee..489286e 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -105,6 +105,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -191,6 +195,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 6a80e72..5da8eca 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -154,6 +154,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -269,6 +273,12 @@ If no, lvm will store metadata on the PV.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 1140d69..499f62c 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -69,6 +69,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -137,6 +141,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index c4b03da..2b4fb1c 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -145,6 +145,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -274,6 +278,12 @@ Specifies the type of on-disk metadata to use.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--norestorefile\fP
 .br
 In conjunction with --uuid, this allows a uuid to be specified
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index bbf09d8..5f39e7b 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -166,6 +166,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -306,6 +310,12 @@ Useful if grepping the output.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--nosuffix\fP
 .br
 Suppress the suffix on output sizes. Use with --units
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index cb121f2..e553722 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -137,6 +137,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -260,6 +264,12 @@ Move only the extents belonging to the named LV.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 16a82ad..3d83478 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -79,6 +79,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -145,6 +149,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index 7b61f81..5a5c975 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -74,6 +74,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -133,6 +137,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index a2a62a6..59f1e3d 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -72,10 +72,6 @@ pvs produces formatted output about PVs.
 .ad b
 .br
 .ad l
-[    \fB--nolocking\fP ]
-.ad b
-.br
-.ad l
 [    \fB--nosuffix\fP ]
 .ad b
 .br
@@ -170,6 +166,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 230492b..3ce59b5 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -218,6 +218,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -323,6 +327,12 @@ The minor number of a device.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB-n\fP|\fB--novolumegroup\fP
 .br
 Only show PVs not belonging to any VG.
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index e9c42fe..cd2521a 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -105,6 +105,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -186,6 +190,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index cffd44b..b4e2183 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -55,6 +55,10 @@ vgcfgrestore - Restore volume group configuration
 .ad b
 .br
 .ad l
+    \fB--nolocking\fP
+.ad b
+.br
+.ad l
     \fB--profile\fP \fIString\fP
 .ad b
 .br
@@ -197,6 +201,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -288,6 +296,12 @@ Specifies the type of on-disk metadata to use.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 00cfc2b..a9ac546 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -31,10 +31,6 @@ vgchange - Change volume group attributes
 .ad b
 .br
 .ad l
- \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
-.ad b
-.br
-.ad l
     \fB--commandprofile\fP \fIString\fP
 .ad b
 .br
@@ -119,6 +115,10 @@ vgchange - Change volume group attributes
 .ad b
 .br
 .ad l
+    \fB--nolocking\fP
+.ad b
+.br
+.ad l
     \fB--noudevsync\fP
 .ad b
 .br
@@ -218,10 +218,6 @@ required, after which the others are optional.
 .ad b
 .br
 .ad l
-  \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP,
-.ad b
-.br
-.ad l
   \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT],
 .ad b
 .br
@@ -637,6 +633,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -722,13 +722,6 @@ Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information
 .ad b
 .HP
 .ad l
-\fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
-.br
-Change the clustered property of a VG using clvmd.
-See \fBclvmd\fP(8) for more information about clustered VGs.
-.ad b
-.HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
@@ -881,6 +874,12 @@ See \fBdmeventd\fP(8) for more information.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index 83e4a19..b1418f3 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -74,6 +74,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -133,6 +137,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index 5e7f8a9..16e1fc8 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -95,6 +95,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -199,6 +203,12 @@ Specifies the type of on-disk metadata to use.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 09bf126..cc990cc 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -152,6 +152,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -199,11 +203,8 @@ Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information
 .ad l
 \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
 .br
-Create a clustered VG using clvmd if LVM is compiled with cluster support.
-This allows multiple hosts to share a VG on shared devices.
-clvmd and a lock manager must be configured and running.
-(A clustered VG using clvmd is different from a shared VG using lvmlockd.)
-See \fBclvmd\fP(8) for more information about clustered VGs.
+This option was specific to clvm and is now replaced by
+the --shared option with \fBlvmlockd\fP(8).
 .ad b
 .HP
 .ad l
@@ -332,6 +333,12 @@ Specifies the type of on-disk metadata to use.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
 .br
 Sets the physical extent size of PVs in the VG.
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index dcf9934..89e3603 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -161,6 +161,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -295,6 +299,12 @@ Useful if grepping the output.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--nosuffix\fP
 .br
 Suppress the suffix on output sizes. Use with --units
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index 1dd715e..a87c871 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -108,6 +108,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -172,6 +176,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index a6a30e9..a2aff35 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -123,6 +123,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -245,6 +249,12 @@ Specifies the type of on-disk metadata to use.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index 71f9d56..f3d86df 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -98,6 +98,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -170,6 +174,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index aab34f4..0d0eb84 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -78,6 +78,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -154,6 +158,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index ab6873d..8b599f8 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -75,6 +75,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -147,6 +151,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 9588694..1cff786 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -86,6 +86,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -152,6 +156,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index ecc5aca..fd92266 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -53,6 +53,10 @@ vgreduce - Remove physical volume(s) from a volume group
 .ad b
 .br
 .ad l
+    \fB--nolocking\fP
+.ad b
+.br
+.ad l
     \fB--profile\fP \fIString\fP
 .ad b
 .br
@@ -187,6 +191,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -272,6 +280,12 @@ Only remove missing PVs from mirror LVs.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index f562991..69f2831 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -89,6 +89,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -155,6 +159,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--noudevsync\fP
 .br
 Disables udev synchronisation. The process will not wait for notification
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index 1f8928e..0313cf8 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -102,6 +102,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -175,6 +179,12 @@ Display long help text.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index efceb4e..681711b 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -68,10 +68,6 @@ vgs produces formatted output about VGs.
 .ad b
 .br
 .ad l
-[    \fB--nolocking\fP ]
-.ad b
-.br
-.ad l
 [    \fB--nosuffix\fP ]
 .ad b
 .br
@@ -166,6 +162,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 18b2990..fe9f201 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -85,6 +85,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -164,6 +168,12 @@ LVs and creates any missing ones and removes unused ones.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--notifydbus\fP
 .br
 Send a notification to D-Bus. The command will exit with an error
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 6c3e6ec..c1e7f4e 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -50,10 +50,6 @@ Common options for command:
 .ad b
 .br
 .ad l
-[ \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP ]
-.ad b
-.br
-.ad l
 [ \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP ]
 .ad b
 .br
@@ -122,6 +118,10 @@ Common options for lvm:
 .ad b
 .br
 .ad l
+[    \fB--nolocking\fP ]
+.ad b
+.br
+.ad l
 [    \fB--profile\fP \fIString\fP ]
 .ad b
 .br
@@ -160,12 +160,6 @@ Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information
 .ad b
 .HP
 .ad l
-\fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
-.br
-Specifies the clustered property of the new VG.
-.ad b
-.HP
-.ad l
 \fB--commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
@@ -244,6 +238,12 @@ Move only PVs used by the named LV.
 .ad b
 .HP
 .ad l
+\fB--nolocking\fP
+.br
+Disable locking.
+.ad b
+.HP
+.ad l
 \fB--profile\fP \fIString\fP
 .br
 An alias for --commandprofile or --metadataprofile, depending


