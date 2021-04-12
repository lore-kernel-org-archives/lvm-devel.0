From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:43 +0000 (GMT)
Subject: main - man: use commas in SEE ALSO
Message-ID: <20210412075543.079773835429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b76283c4b377b3fffd5c20974e4a99e6407d71cb
Commit:        b76283c4b377b3fffd5c20974e4a99e6407d71cb
Parent:        f5efe1beb53dde57bd83c4b50e001b3feceaa983
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 11 21:11:02 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

man: use commas in SEE ALSO

Add ',' between each ref.
Use left alignment and no hyphenation.
---
 man/lvm.8_main       | 117 +++++++++++++++++++++++++------------------------
 man/lvmreport.7_main |   6 +--
 man/see_also.end     | 121 ++++++++++++++++++++++++++-------------------------
 3 files changed, 123 insertions(+), 121 deletions(-)

diff --git a/man/lvm.8_main b/man/lvm.8_main
index 1e03b8cb9..b221761e3 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -497,70 +497,71 @@ Prepends source file name and code line number with libdm debugging.
 .SH SEE ALSO
 .
 .nh
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
 
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
-.BR lvmcache (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
+.BR lvmcache (7),
 
 .BR dmsetup (8),
 .BR dmstats (8),
diff --git a/man/lvmreport.7_main b/man/lvmreport.7_main
index aca1b4940..d6943b9df 100644
--- a/man/lvmreport.7_main
+++ b/man/lvmreport.7_main
@@ -1805,6 +1805,6 @@ lvm> abc
 .fi
 
 .SH SEE ALSO
-\fBlvm\fP (8),
-\fBlvmconfig\fP (8),
-\fBlvm fullreport\fP (8)
+.BR lvm (8),
+.BR lvmconfig (8),
+.BR "lvm fullreport" (8)
diff --git a/man/see_also.end b/man/see_also.end
index 4dc9b0ec0..dbe4bc1c1 100644
--- a/man/see_also.end
+++ b/man/see_also.end
@@ -1,68 +1,69 @@
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
-
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)


