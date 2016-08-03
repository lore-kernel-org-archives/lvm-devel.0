From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  3 Aug 2016 20:42:27 +0000 (UTC)
Subject: master - man: include info about disabled lvmetad
Message-ID: <20160803204227.769CB60E90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b01dca28aca71af1388e96d4ed3627d352d9399
Commit:        2b01dca28aca71af1388e96d4ed3627d352d9399
Parent:        8b1a368b59f0759dca84be663663011622b0cd99
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 3 15:39:43 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 3 15:42:12 2016 -0500

man: include info about disabled lvmetad

---
 man/lvmetad.8.in |   38 ++++++++++++++++++++++++--------------
 1 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index 3e895ce..c665e18 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -19,35 +19,45 @@ lvmetad \(em LVM metadata cache daemon
 
 .SH DESCRIPTION
 
-The lvmetad daemon caches LVM metadata, so that LVM commands can read
-metadata without scanning disks.
-
-Metadata caching can be an advantage because scanning disks is time
-consuming and may interfere with the normal work of the system and disks.
-
-lvmetad does not read metadata from disks itself.  The 'pvscan \-\-cache'
-command scans disks, reads the LVM metadata and sends it to lvmetad.
-
-New LVM disks that appear on the system must be scanned by pvscan before
-lvmetad knows about them.  If lvmetad does not know about a disk, then LVM
+The lvmetad daemon caches LVM metadata so that LVM commands can read
+metadata from the cache rather than scanning disks.  This can be an
+advantage because scanning disks is time consuming and may interfere with
+the normal work of the system.  lvmetad can be a disadvantage when disk
+event notifications from the system are unreliable.
+
+lvmetad does not read metadata from disks itself.  Instead, it relies on
+an LVM command, like pvscan \-\-cache, to read metadata from disks and
+send it to lvmetad to be cached.
+
+New LVM disks that appear on the system must be scanned before lvmetad
+knows about them.  If lvmetad does not know about a disk, then LVM
 commands using lvmetad will also not know about it.  When disks are added
 or removed from the system, lvmetad must be updated.
 
-lvmetad is usually combined with event-based system services that
-automatically run pvscan \-\-cache on new disks.  This way, the lvmetad
-cache is automatically updated with metadata from new disks when they
+lvmetad is usually combined with event\-based system services that
+automatically run pvscan \-\-cache on disks added or removed.  This way,
+the cache is automatically updated with metadata from new disks when they
 appear.  LVM udev rules and systemd services implement this automation.
 Automatic scanning is usually combined with automatic activation.  For
 more information, see
 .BR pvscan (8).
 
 If lvmetad is started or restarted after disks have been added to the
-system, or if the global_filter has changed, the cache must be updated by
-running 'pvscan \-\-cache'.
+system, or if the global_filter has changed, the cache must be updated.
+This can be done by running pvscan \-\-cache, or it will be done
+automatically by the next LVM command that's run.
 
 When lvmetad is not used, LVM commands revert to scanning disks for LVM
 metadata.
 
+In some cases, lvmetad will be temporarily disabled while it continues
+running.  In this state, LVM commands will ignore the lvmetad cache and
+revert to scanning disks.  A warning will also be printed which includes
+the reason why lvmetad is not being used.  The most common reason is the
+existence of duplicate PVs (lvmetad cannot cache data for duplicate PVs.)
+Once duplicates have been resolved, the lvmetad cache is can be updated
+with pvscan \-\-cache and commands will return to using the cache.
+
 Use of lvmetad is enabled/disabled by:
 .br
 .BR lvm.conf (5)


