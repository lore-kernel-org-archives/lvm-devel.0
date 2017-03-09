From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 9 Mar 2017 13:54:18 -0500
Subject: master - man: add FILE MAPPING section to dmstats.8.in
Message-ID: <201703091854.v29IsIkn029866@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=67ddc0c29289c454fbe6203473790bbcd12e3619
Commit:        67ddc0c29289c454fbe6203473790bbcd12e3619
Parent:        b5c8accdf2d503102cd701c2e2104ef67ce0f6db
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 18 18:14:04 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 9 18:50:15 2017 +0000

man: add FILE MAPPING section to dmstats.8.in

Add a section to explain file mapping, outside of the individual
command descriptions, and to describe the limitations of the
current update strategy.
---
 man/dmstats.8.in |   87 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 87 insertions(+), 0 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index b9bc781..682f01d 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -825,6 +825,93 @@ containing device.
 The \fBgroup_id\fP should be treated as an opaque identifier used to
 reference the group.
 .
+.SH FILE MAPPING
+.
+Using \fB\-\-filemap\fP, it is possible to create regions that
+correspond to the extents of a file in the file system. This allows
+IO statistics to be monitored on a per-file basis, for example to
+observe large database files, virtual machine images, or other files
+of interest.
+
+To be able to use file mapping, the file must be backed by a
+device-mapper device, and in a file system that supports the FIEMAP
+ioctl (and which returns data describing the physical location of
+extents). This currently includes \fBxfs(5)\fP and \fBext4(5)\fP.
+
+By default the regions making up a file are placed together in a
+group, and the group alias is set to the \fBbasename(3)\fP of the
+file. This allows statistics to be reported for the file as a whole,
+aggregating values for the regions making up the group. To see only
+the whole file (group) when using the \fBlist\fP and \fBreport\fP
+commands, use \fB\-\-group\fP.
+
+Since it is possible for the file to change after the initial
+group of regions is created, the \fBupdate_filemap\fP command, and
+\fBdmfilemapd\fP daemon are provided to update file mapped groups
+either manually or automatically.
+.
+.P
+.B File follow modes
+.P
+The file map monitoring daemon can monitor files in two distinct ways:
+follow-inode mode, and follow-path mode.
+
+The mode affects the behaviour of the daemon when a file under
+monitoring is renamed or unlinked, and the conditions which cause the
+daemon to terminate.
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
+not replaced within a brief tolerance interval (one second).
+
+To stop the daemon, delete the group containing the mapped regions:
+the daemon will automatically shut down.
+
+The daemon can also be safely killed at any time and the group kept:
+if the file is still being allocated the mapping will become
+progressively out-of-date as extents are added and removed (in this
+case the daemon can be re-started or the group updated manually with
+the \fBupdate_filemap\fP command).
+
+See the \fBcreate\fP command and \fB\-\-filemap\fP, \fB\-\-follow\fP,
+and \fB\-\-nomonitor\fP options for further information.
+.
+.P
+.B Limitations
+.P
+The daemon attempts to maintain good synchronisation between the file
+extents and the regions contained in the group, however, since it can
+only react to new allocations once they have been written, there are
+inevitably some IO events that cannot be counted when a file is
+growing, particularly if the file is being extended by a single thread
+writing beyond end-of-file (for example, the \fBdd\fP program).
+
+There is a further loss of events in that there is currently no way
+to atomically resize a \fBdmstats\fP region and preserve its current
+counter values. This affects files when they grow by extending the
+final extent, rather than allocating a new extent: any events that
+had accumulated in the region between any prior operation and the
+resize are lost.
+
+File mapping is currently most effective in cases where the majority
+of IO does not trigger extent allocation. Future updates may address
+these limitations when kernel support is available.
+.
 .SH REPORT FIELDS
 .
 The dmstats report provides several types of field that may be added to


