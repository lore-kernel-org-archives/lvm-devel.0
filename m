From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  1 May 2015 20:25:42 +0000 (UTC)
Subject: master - man: expanded explanation of lvmetad
Message-ID: <20150501202542.549FA60DA3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a171bbdf5bc579670b225c291421eb8ee14d2c3
Commit:        6a171bbdf5bc579670b225c291421eb8ee14d2c3
Parent:        9273b1a964c4edafbc59598f7a800f5cd524a8f3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 1 14:45:50 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 1 15:23:43 2015 -0500

man: expanded explanation of lvmetad

---
 man/lvmetad.8.in |   63 +++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 53 insertions(+), 10 deletions(-)

diff --git a/man/lvmetad.8.in b/man/lvmetad.8.in
index 3ea80c9..cdaf198 100644
--- a/man/lvmetad.8.in
+++ b/man/lvmetad.8.in
@@ -1,6 +1,7 @@
 .TH LVMETAD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
 .SH NAME
 lvmetad \(em LVM metadata cache daemon
+
 .SH SYNOPSIS
 .B lvmetad
 .RB [ \-l
@@ -13,16 +14,56 @@ lvmetad \(em LVM metadata cache daemon
 .RB [ \-h ]
 .RB [ \-V ]
 .RB [ \-? ]
+
 .SH DESCRIPTION
-lvmetad is a metadata caching daemon for LVM. The daemon receives notifications
-from udev rules (which must be installed for LVM to work correctly when lvmetad
-is in use). Through these notifications, lvmetad has an up-to-date and
-consistent image of the volume groups available in the system.
-
-lvmetad is used by LVM only if it is enabled in \fBlvm.conf\fP(5) by specifying the
-\fBglobal/use_lvmetad\fP setting. If this is not defined in the LVM configuration
-explicitly then default setting is used instead (see the output of
-\fBlvmconfig \-\-type default global/use_lvmetad\fP command).
+
+The lvmetad daemon caches LVM metadata, so that LVM commands can read
+metadata without scanning disks.
+
+Metadata caching can be an advantage because scanning disks is time
+consuming and may interfere with the normal work of the system and disks.
+
+lvmetad does not read metadata from disks itself.  The 'pvscan \-\-cache'
+command scans disks, reads the LVM metadata and sends it to lvmetad.
+
+New LVM disks that appear on the system must be scanned by pvscan before
+lvmetad knows about them.  If lvmetad does not know about a disk, then LVM
+commands using lvmetad will also not know about it.  When disks are added
+or removed from the system, lvmetad must be updated.
+
+lvmetad is usually combined with event-based system services that
+automatically run pvscan \-\-cache on new disks.  This way, the lvmetad
+cache is automatically updated with metadata from new disks when they
+appear.  LVM udev rules and systemd services implement this automation.
+Automatic scanning is usually combined with automatic activation.  For
+more information, see
+.BR pvscan (8).
+
+If lvmetad is started or restarted after disks have been added to the
+system, or if the global_filter has changed, the cache must be updated by
+running 'pvscan \-\-cache'.
+
+When lvmetad is not used, LVM commands revert to scanning disks for LVM
+metadata.
+
+Use of lvmetad is enabled/disabled by:
+.br
+.BR lvm.conf (5)
+.B global/use_lvmetad
+
+For more information on this setting, see:
+.br
+.B lvmconfig \-\-withcomments global/use_lvmetad
+
+To ignore disks from LVM at the system level, e.g. lvmetad, pvscan use:
+.br
+.BR lvm.conf (5)
+.B devices/global_filter
+
+For more information on this setting, see
+.br
+.B lvmconfig \-\-withcomments devices/global_filter
+
 .SH OPTIONS
 
 To run the daemon in a test environment both the pidfile_path and the
@@ -68,4 +109,6 @@ Path for the socket file.
 
 .SH SEE ALSO
 .BR lvm (8),
-.BR lvm.conf (5)
+.BR lvmconfig (8),
+.BR lvm.conf (5),
+.BR pvscan (8)


