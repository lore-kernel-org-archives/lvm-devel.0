From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  6 Jul 2015 20:33:37 +0000 (UTC)
Subject: master - man lvmlockd: minor updates
Message-ID: <20150706203337.C28B06024D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a8cc1dcd41f12a48108744b9070405169e7853f
Commit:        6a8cc1dcd41f12a48108744b9070405169e7853f
Parent:        c923dee8de0fd01ca1538ecf783fb6c1dfa9d127
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 6 15:32:41 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 6 15:32:41 2015 -0500

man lvmlockd: minor updates

---
 man/lvmlockd.8.in |   36 +++++++++++++++++++++++++-----------
 1 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 3710df6..4d9b3f5 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -72,6 +72,10 @@ For default settings, see lvmlockd -h.
 .I path
         A file containing the local sanlock host_id.
 
+.B  --sanlock-timeout | -o
+.I seconds
+        Override the default sanlock I/O timeout.
+
 .B  --adopt | A 0|1
         Adopt locks from a previous instance of lvmlockd.
 
@@ -242,6 +246,9 @@ lvmlockd.  From a host not using lvmlockd, visible lockd VGs are ignored
 in the same way as foreign VGs, i.e. those with a foreign system ID, see
 .BR lvmsystemid (7).
 
+The --shared option displays lockd VGs on a host not using lvmlockd, like
+the --foreign option does for foreign VGs.
+
 
 .SS vgcreate differences
 
@@ -290,12 +297,12 @@ exists, VGs can still be read, but commands that require the global lock
 exclusively will fail.
 
 When a new lockd VG is created, its lockspace is automatically started on
-the host that creates the VG.  Other hosts will need to run 'vgcreate
+the host that creates the VG.  Other hosts will need to run 'vgchange
 --lock-start' to start the new VG before they can use it.
 
-From the 'vgs' reporting command, lockd VGs are indicated by "s" (for
-shared) in the sixth attr field.  The specific lock type and lock args
-for a lockd VG can be displayed with 'vgs -o+locktype,lockargs'.
+From the 'vgs' command, lockd VGs are indicated by "s" (for shared) in the
+sixth attr field.  The specific lock type and lock args for a lockd VG can
+be displayed with 'vgs -o+locktype,lockargs'.
 
 
 .SS starting and stopping VGs
@@ -419,7 +426,7 @@ enabled unless lockd VGs will be used.
 A VG lock is associated with each VG.  The VG lock is acquired in shared
 mode to read the VG and in exclusive mode to change the VG (modify the VG
 metadata).  This lock serializes modifications to a VG with all other LVM
-commands on other hosts.
+commands accessing the VG from all hosts.
 
 The command 'vgs' will not only acquire the GL lock to read the list of
 all VG names, but will acquire the VG lock for each VG prior to reading
@@ -458,7 +465,7 @@ contain disabled global locks that can be enabled later if necessary.
 The VG containing the global lock must be visible to all hosts using
 sanlock VGs.  This can be a reason to create a small sanlock VG, visible
 to all hosts, and dedicated to just holding the global lock.  While not
-required, this strategy can help to avoid extra work in the future if VGs
+required, this strategy can help to avoid difficulty in the future if VGs
 are moved or removed.
 
 The vgcreate command typically acquires the global lock, but in the case
@@ -509,7 +516,7 @@ Changing a lockd VG to a local VG is not yet generally allowed.
 (It can be done partially in certain recovery cases.)
 
 
-.SS vgremove of a sanlock VG
+.SS vgremove and vgreduce with sanlock VGs
 
 vgremove of a sanlock VG will fail if other hosts have the VG started.
 Run vgchange --lock-stop <vg_name> on all other hosts before vgremove.
@@ -517,6 +524,9 @@ Run vgchange --lock-stop <vg_name> on all other hosts before vgremove.
 (It may take several seconds before vgremove recognizes that all hosts
 have stopped.)
 
+A sanlock VG contains a hidden LV called "lvmlock" that holds the sanlock
+locks.  vgreduce cannot yet remove the PV holding the lvmlockd LV.
+
 
 .SS shared LVs
 
@@ -615,7 +625,7 @@ same lease exclusively at once, so the same LV should never be active on
 two hosts at once when activated exclusively.
 
 The current method of handling this involves no action from lvmlockd,
-while allowing sanlock to protect the leases itself.  This produces a safe
+which allows sanlock to protect the leases itself.  This produces a safe
 but potentially inconvenient result.  Doing nothing from lvmlockd leads to
 the host's LV locks not being released, which leads to sanlock using the
 local watchdog to reset the host before another host can acquire any locks
@@ -738,9 +748,13 @@ stopped the lockspace for the VG.  Stop the VG lockspace on all uses using
 vgchange --lock-stop.
 
 .IP \[bu] 2
-Long lasting lock contention among hosts may result in a command giving up
-and failing.  The number of lock retries can be adjusted with
-global/lvmlockd_lock_retries.
+vgreduce of a PV in a sanlock VG may fail if it holds the internal
+"lvmlock" LV that holds the sanlock locks.
+
+.IP \[bu] 2
+lvmlockd uses lock retries instead of lock queueing, so high lock
+contention may require increasing global/lvmlockd_lock_retries to
+avoid transient lock contention failures.
 
 .IP \[bu] 2
 The reporting options locktype and lockargs can be used to view lockd VG


