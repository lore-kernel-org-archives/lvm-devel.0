From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 12 Jan 2016 18:02:28 +0000 (UTC)
Subject: master - man lvmlockd: mention pvmove restriction
Message-ID: <20160112180228.22A5F602AF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e336582f4c9ba185ff7c9ba1031066fbeed863e
Commit:        9e336582f4c9ba185ff7c9ba1031066fbeed863e
Parent:        0c6946b4ce2fc664a66cd68a4fb2324bfb69b5ab
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 12 12:01:53 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 12 12:01:53 2016 -0600

man lvmlockd: mention pvmove restriction

---
 man/lvmlockd.8.in |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 4e7abdf..f01c695 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -566,7 +566,8 @@ where the GL lock must be manually enabled after a vgremove.
 A sanlock VG contains a hidden LV called "lvmlock" that holds the sanlock
 locks.  vgreduce cannot yet remove the PV holding the lvmlock LV.  To
 remove this PV, change the VG lock type to "none", run vgreduce, then
-change the VG lock type back to "sanlock".
+change the VG lock type back to "sanlock".  Similarly, pvmove cannot be
+used on a PV used by the lvmlock LV.
 
 To place the lvmlock LV on a specific device, create the VG with only that
 device, then use vgextend to add other devices.
@@ -852,8 +853,8 @@ stopped the VG lockspace.  Stop the VG on all hosts using vgchange
 \-\-lock-stop.
 
 .IP \[bu] 2
-vgreduce of a PV in a sanlock VG may fail if it holds the internal
-"lvmlock" LV that holds the sanlock locks.
+vgreduce or pvmove of a PV in a sanlock VG will fail if it holds the
+internal "lvmlock" LV that holds the sanlock locks.
 
 .IP \[bu] 2
 lvmlockd uses lock retries instead of lock queueing, so high lock


