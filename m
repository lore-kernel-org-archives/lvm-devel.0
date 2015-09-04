From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  4 Sep 2015 16:05:21 +0000 (UTC)
Subject: master - man lvmlockd: explain the use of lvmlockctl kill
Message-ID: <20150904160521.37BAE61264@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b00ee99a21f3a6f502fc5d165b979af128e3b8b2
Commit:        b00ee99a21f3a6f502fc5d165b979af128e3b8b2
Parent:        55c13f3de4a8b709b950297369182cd81a6c738f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 4 10:29:01 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 4 11:05:13 2015 -0500

man lvmlockd: explain the use of lvmlockctl kill

---
 man/lvmlockd.8.in |   30 ++++++++++++++++++++----------
 1 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 4e7883a..02fa338 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -536,7 +536,7 @@ Run vgchange \-\-lock-stop <vgname> on all other hosts before vgremove.
 have stopped.)
 
 A sanlock VG contains a hidden LV called "lvmlock" that holds the sanlock
-locks.  vgreduce cannot yet remove the PV holding the lvmlockd LV.  To
+locks.  vgreduce cannot yet remove the PV holding the lvmlock LV.  To
 remove this PV, change the VG lock type to "none", run vgreduce, then
 change the VG lock type back to "sanlock".
 
@@ -590,13 +590,20 @@ the dlm/corosync recovery process is complete.
 
 .B sanlock lease storage failure
 
-If a host loses access to the device holding a VG's locks, sanlock cannot
-renew its lease for the VG's locks.  After some time, the lease will
-expire, and locks held by the host can be acquired by other hosts.
+If the PV under a sanlock VG's lvmlock LV is disconnected, unresponsive or
+too slow, sanlock cannot renew the lease for the VG's locks.  After some
+time, the lease will expire, and locks that the host owns in the VG can be
+acquired by other hosts.  The VG must be forcibly deactivated on the host
+with the expiring lease before other hosts can acquire its locks.
 
-If no LVs are active in the VG, the lockspace with an expiring lease will
-be shut down, and errors will be reported when trying to use the VG.  Use
-the lvmlockctl \-\-drop command to clear the stale lockspace from
+When the sanlock daemon detects that the lease storage is lost, it runs
+the command lvmlockctl \-\-kill <vgname>.  This command emits a syslog
+message stating that lease storage is lost for the VG and LVs must be
+immediately deactivated.
+
+If no LVs are active in the VG, then the lockspace with an expiring lease
+will be removed, and errors will be reported when trying to use the VG.
+Use the lvmlockctl \-\-drop command to clear the stale lockspace from
 lvmlockd.
 
 If the VG has active LVs when the lock storage is lost, the LVs must be
@@ -607,9 +614,12 @@ about 40 seconds, sanlock will reset the host using the local watchdog.
 The machine reset is effectively a severe form of "deactivating" LVs
 before they can be activated on other hosts.  The reset is considered a
 better alternative than having LVs used by multiple hosts at once, which
-could easily damage or destroy their content.  A future enhancement may
-automatically attempt to forcibly deactivate LVs before the lockspace
-lease expires.
+could easily damage or destroy their content.
+
+In the future, the lvmlockctl kill command may automatically attempt to
+forcibly deactivate LVs before the sanlock lease expires.  Until then, the
+user must notice the syslog message and manually deactivate the VG before
+sanlock resets the machine.
 
 .B sanlock daemon failure
 


