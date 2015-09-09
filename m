From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  9 Sep 2015 20:21:50 +0000 (UTC)
Subject: master - man lvmlockd: mention device used for first vgcreate
Message-ID: <20150909202150.6AC1760C85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81b0e9de7c28e1516263427d270907c4781964e1
Commit:        81b0e9de7c28e1516263427d270907c4781964e1
Parent:        587fd6a0e479f630ad4d574d391f269048a81186
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 9 15:21:10 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 9 15:21:10 2015 -0500

man lvmlockd: mention device used for first vgcreate

---
 man/lvmlockd.8.in |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 7df0feb..15f9b73 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -306,10 +306,17 @@ they are not available until the VG exists.  The first sanlock VG will
 contain the "global lock".
 
 .IP \[bu] 2
-While running vgcreate for the first sanlock VG, ensure that the PV being
-used is not used by another LVM command.  Allocation of shared PVs is
-usually protected by the global lock, but this cannot be done for the
-first sanlock VG which will hold the global lock.
+The first vgcreate command needs to be given the path to a device that has
+not yet been initialized with pvcreate.  The pvcreate initialization will
+be done by vgcreate.  This is because the pvcreate command requires the
+global lock, which will not available until after the first sanlock VG is
+created.
+
+.IP \[bu] 2
+While running vgcreate for the first sanlock VG, ensure that the device
+being used is not used by another LVM command.  Allocation of shared
+devices is usually protected by the global lock, but this cannot be done
+for the first sanlock VG which will hold the global lock.
 
 .IP \[bu] 2
 While running vgcreate for the first sanlock VG, ensure that the VG name
@@ -321,7 +328,7 @@ Because the first sanlock VG will contain the global lock, this VG needs
 to be accessible to all hosts that will use sanlock shared VGs.  All hosts
 will need to use the global lock from the first sanlock VG.
 
-See below for other special cases related to moving the global lock.
+See below for more information about managing the sanlock global lock.
 
 
 .SS using lockd VGs


