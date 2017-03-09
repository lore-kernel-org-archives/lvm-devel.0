From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 9 Mar 2017 13:54:13 -0500
Subject: master - man: add dmfilemapd options to dmstats.8.in
Message-ID: <201703091854.v29IsDID020503@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5c8accdf2d503102cd701c2e2104ef67ce0f6db
Commit:        b5c8accdf2d503102cd701c2e2104ef67ce0f6db
Parent:        baa8a9be4adb3e1d57b4b135178e7f77d8580902
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Dec 17 16:41:00 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 9 18:50:15 2017 +0000

man: add dmfilemapd options to dmstats.8.in

Add descriptions of --follow and --nomonitor, and the behaviour
of create and update_filemap when starting dmfilemapd.
---
 man/dmstats.8.in |   85 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 80 insertions(+), 5 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index ba828dc..b9bc781 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -14,6 +14,9 @@
 .  RB [ \-\-region ]
 .  RB [ \-\-group ]
 ..
+.de OPT_FOREGROUND
+.  RB [ \-\-foreground ]
+..
 .
 .\" Print units suffix, use with arg to print human
 .\" man2html can't handle too many changes per command
@@ -89,6 +92,10 @@ dmstats \(em device-mapper statistics management
 .  RB [ \-\-bounds
 .  IR \%histogram_boundaries ]
 .  RB [ \-\-filemap ]
+.  RB [ \-\-follow
+.  IR follow_mode ]
+.  OPT_FOREGROUND
+.  RB [ \-\-nomonitor ]
 .  RB [ \-\-nogroup ]
 .  RB [ \-\-precise ]
 .  RB [ \-\-start
@@ -215,6 +222,9 @@ dmstats \(em device-mapper statistics management
 .  IR file_path
 .  RB [ \-\-groupid
 .  IR id ]
+.  RB [ \-\-follow
+.  IR follow_mode ]
+.  OPT_FOREGROUND
 .  ad b
 ..
 .CMD_UPDATE_FILEMAP
@@ -314,6 +324,60 @@ create regions corresponding to the locations of the on-disk extents
 allocated to the file(s).
 .
 .HP
+.BR \-\-nomonitor
+.br
+Disable the \fBdmfilemapd\fP daemon when creating new file mapped
+groups. Normally the device-mapper filemap monitoring daemon,
+\fBdmfilemapd\fP, is started for each file mapped group to update the
+set of regions as the file changes on-disk: use of this option
+disables this behaviour.
+
+Regions in the group may still be updated with the
+\fBupdate_filemap\fP command, or by starting the daemon manually.
+.
+.HP
+.BR \-\-follow
+.IR follow_mode
+.br
+Specify the \fBdmfilemapd\fP file following mode. The file map
+monitoring daemon can monitor files in two distinct ways: the mode
+affects the behaviour of the daemon when a file under monitoring is
+renamed or unlinked, and the conditions which cause the daemon to
+terminate.
+
+The \fBfollow_mode\fP argument is either "inode", for follow-inode
+mode, or "path", for follow-path.
+
+If follow-inode mode is used, the daemon will hold the file open, and
+continue to update regions from the same file descriptor. This means
+that the mapping will follow rename, move (within the same file
+system), and unlink operations. This mode is useful if the file is
+expected to be moved, renamed, or unlinked while it is being
+monitored.
+
+In follow-inode mode, the daemon will exit once it detects that the
+file has been unlinked and it is the last holder of a reference to it.
+
+If follow-path is used, the daemon will re-open the provided path on
+each monitoring iteration. This means that the group will be updated
+to reflect a new file being moved to the same path as the original
+file. This mode is useful for files that are expected to be updated
+via unlink and rename.
+
+In follow-path mode, the daemon will exit if the file is removed and
+not replaced within a brief tolerance interval.
+
+In either mode, the daemon exits automatically if the monitored group
+is removed.
+.
+.HP
+.BR \-\-foreground
+.br
+Specify that the \fBdmfilemapd\fP daemon should run in the foreground.
+The daemon will not fork into the background, and will replace the
+\fBdmstats\fP command that started it.
+.
+.HP
 .BR \-\-groupid
 .IR id
 .br
@@ -568,6 +632,11 @@ By default regions that map a file are placed into a group and the
 group alias is set to the basename of the file. This behaviour can be
 overridden with the \fB\-\-alias\fP and \fB\-\-nogroup\fP options.
 
+Creating a group that maps a file automatically starts a daemon,
+\fBdmfilemapd\fP to monitor the file and update the mapping as the
+extents allocated to the file change. This behaviour can be disabled
+using the \fB\-\-nomonitor\fP option.
+
 Use the \fB\-\-group\fP option to only display information for groups
 when listing and reporting.
 .
@@ -678,17 +747,23 @@ The group to be removed is specified using \fB\-\-groupid\fP.
 .CMD_UPDATE_FILEMAP
 .br
 Update a group of \fBdmstats\fP regions specified by \fBgroup_id\fP,
-that were previously created with \fB\-\-filemap\fP. This will add
-and remove regions to reflect changes in the allocated extents of
-the file on-disk, since the time that it was crated or last updated.
+that were previously created with \fB\-\-filemap\fP, either directly,
+or by starting the monitoring daemon, \fBdmfilemapd\fP.
+
+This will add and remove regions to reflect changes in the allocated
+extents of the file on-disk, since the time that it was crated or last
+updated.
 
 Use of this command is not normally needed since the \fBdmfilemapd\fP
 daemon will automatically monitor filemap groups and perform these
 updates when required.
 
-If a filemapped group was created with \fB\-\-nominitor\fP, or the
+If a filemapped group was created with \fB\-\-nomonitor\fP, or the
 daemon has been killed, the \fBupdate_filemap\fP can be used to
-manually force an update.
+manually force an update or start a new daemon.
+
+Use \fB\-\-nomonitor\fP to force a direct update and disable starting
+the monitoring daemon.
 .
 .SH REGIONS, AREAS, AND GROUPS
 .


