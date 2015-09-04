From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  4 Sep 2015 18:03:17 +0000 (UTC)
Subject: master - man lvmlockd: add section about first sanlock VG
Message-ID: <20150904180317.B626C61056@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=43d6b5b375e97fa96c9fe498a19fe6df05dc1fb2
Commit:        43d6b5b375e97fa96c9fe498a19fe6df05dc1fb2
Parent:        869c0bdeb89b7f78bb5152ca1278cfb0cc5d9fd5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 4 13:01:03 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 4 13:01:03 2015 -0500

man lvmlockd: add section about first sanlock VG

Add a section specifically about creating the first
sanlock VG.
---
 man/lvmlockd.8.in |   45 ++++++++++++++++++++++++++++++++++-----------
 1 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 02fa338..7df0feb 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -298,6 +298,32 @@ LVM commands request locks from clvmd to use the VG.
 
 .P
 
+.SS creating the first sanlock VG
+
+Creating the first sanlock VG is not protected by locking and requires
+special attention.  This is because sanlock locks exist within the VG, so
+they are not available until the VG exists.  The first sanlock VG will
+contain the "global lock".
+
+.IP \[bu] 2
+While running vgcreate for the first sanlock VG, ensure that the PV being
+used is not used by another LVM command.  Allocation of shared PVs is
+usually protected by the global lock, but this cannot be done for the
+first sanlock VG which will hold the global lock.
+
+.IP \[bu] 2
+While running vgcreate for the first sanlock VG, ensure that the VG name
+being used is not used by another LVM command.  Uniqueness of VG names is
+usually ensured by the global lock.
+
+.IP \[bu] 2
+Because the first sanlock VG will contain the global lock, this VG needs
+to be accessible to all hosts that will use sanlock shared VGs.  All hosts
+will need to use the global lock from the first sanlock VG.
+
+See below for other special cases related to moving the global lock.
+
+
 .SS using lockd VGs
 
 There are some special considerations when using lockd VGs.
@@ -479,9 +505,7 @@ global/lvmlockd_lock_retries before failing.  If a request for an LV lock
 fails due to a lock conflict, the command fails immediately.
 
 
-.SS sanlock global lock
-
-There are some special cases related to the global lock in sanlock VGs.
+.SS managing the global lock in sanlock VGs
 
 The global lock exists in one of the sanlock VGs.  The first sanlock VG
 created will contain the global lock.  Subsequent sanlock VGs will each
@@ -526,14 +550,7 @@ A small sanlock VG dedicated to holding the global lock can avoid the case
 where the GL lock must be manually enabled after a vgremove.
 
 
-.SS sanlock VG usage
-
-There are some special cases related to using a sanlock VG.
-
-vgremove of a sanlock VG will fail if other hosts have the VG started.
-Run vgchange \-\-lock-stop <vgname> on all other hosts before vgremove.
-(It may take several seconds before vgremove recognizes that all hosts
-have stopped.)
+.SS internal lvmlock LV
 
 A sanlock VG contains a hidden LV called "lvmlock" that holds the sanlock
 locks.  vgreduce cannot yet remove the PV holding the lvmlock LV.  To
@@ -543,6 +560,12 @@ change the VG lock type back to "sanlock".
 To place the lvmlock LV on a specific device, create the VG with only that
 device, then use vgextend to add other devices.
 
+vgremove of a sanlock VG will fail if other hosts have the VG started.
+Run vgchange \-\-lock-stop <vgname> on all other hosts before vgremove.
+(It may take several seconds before vgremove recognizes that all hosts
+have stopped.)  This is necessary because while a host has a sanlock VG
+started, it is using the internal lvmlock LV.
+
 
 .SS shared LVs
 


