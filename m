From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 20 Oct 2009 23:58:13 -0400
Subject: [PATCH] Document --all option in man pages, cleanup lvdisplay/pvdisplay man page.
In-Reply-To: <4AD83740.5070704@redhat.com>
References: <4AD83740.5070704@redhat.com>
Message-ID: <1256097493-7756-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Option --all is only partially documented currently, so document in all
commands.  Also make lvdisplay/pvdisplay man pages consistent with help
output.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/lvdisplay.8.in |   18 ++++++++++++++++--
 man/lvs.8.in       |    4 ++++
 man/lvscan.8.in    |    4 ++++
 man/pvdisplay.8.in |   15 +++++++++++++--
 man/pvs.8.in       |    4 ++++
 man/vgs.8.in       |    4 ++++
 6 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index 56d33f2..03eb627 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -3,21 +3,35 @@
 lvdisplay \- display attributes of a logical volume
 .SH SYNOPSIS
 .B lvdisplay
+[\-a|\-\-all]
 [\-c|\-\-colon] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure]
-[\-\-maps] [\-P|\-\-partial]
+[\-\-maps]
+[\-\-nosuffix]
+[\-\-units hsbkmgtHKMGT]
+[\-P|\-\-partial]
+[\-\-version]
 [\-v|\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
+.br
+
+.br
+.B lvdisplay \-\-columns | \-C
+[\fB lvs\fP (8) OPTIONS]
 .SH DESCRIPTION
 lvdisplay allows you to see the attributes of a logical volume
 like size, read/write status, snapshot information etc.
 .P
 \fBlvs\fP (8) is an alternative that provides the same information 
 in the style of \fBps\fP (1).  \fBlvs\fP is recommended over
-\fBlvdisplay\fP.
+\fBlvdisplay\fP.  \fBlvdisplay --columns\fP is the equivalent
+of calling \fBlvs\fP.
 
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.I \-\-all
+Process all logical volumes, even hidden/internal ones.
+.TP
 .I \-c, \-\-colon
 Generate colon separated output for easier parsing in scripts or programs.
 N.B. \fBlvs\fP (8) provides considerably more control over the output.
diff --git a/man/lvs.8.in b/man/lvs.8.in
index ff37a99..70ff1e0 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -3,6 +3,7 @@
 lvs \- report information about logical volumes
 .SH SYNOPSIS
 .B lvs
+[\-a|\-\-all]
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
@@ -18,6 +19,9 @@ lvs produces formatted output about logical volumes.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.I \-\-all
+Process all logical volumes, even hidden/internal ones.
+.TP
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
diff --git a/man/lvscan.8.in b/man/lvscan.8.in
index cdcdc1d..ebfb77a 100644
--- a/man/lvscan.8.in
+++ b/man/lvscan.8.in
@@ -3,6 +3,7 @@
 lvscan \- scan (all disks) for logical volumes
 .SH SYNOPSIS
 .B lvscan
+.RB [ \-a | \-\-all]
 .RB [ \-b | \-\-blockdevice ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
@@ -16,6 +17,9 @@ in the system for defined logical volumes.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.BR \-\-all
+Process all logical volumes, even hidden/internal ones.
+.TP
 .BR \-b ", " \-\-blockdevice
 Adds the device major and minor numbers to the display
 of each logical volume.
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index 40d68ad..627b7d3 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -3,16 +3,27 @@
 pvdisplay \- display attributes of a physical volume
 .SH SYNOPSIS
 .B pvdisplay
-[\-c|\-\-colon] [\-d|\-\-debug] [\-h|\-?|\-\-help] [\-s|\-\-short]
+[\-c|\-\-colon]
+[\-d|\-\-debug] [\-h|\-?|\-\-help]
+[\-\-ignorelockingfailure]
+[\-\-maps]
+[\-s|\-\-short]
+[\-\-units hsbkmgtHKMGT]
 [\-v[v]|\-\-verbose [\-\-verbose]]
 PhysicalVolumePath [PhysicalVolumePath...]
+.br
+
+.br
+.B pvdisplay \-\-columns | \-C
+[\fB pvs\fP (8) OPTIONS]
 .SH DESCRIPTION
 pvdisplay allows you to see the attributes of one or more physical volumes
 like size, physical extent size, space used for the volume group descriptor
 area and so on.
 .P
 \fBpvs\fP (8) is an alternative that provides the same information 
-in the style of \fBps\fP (1).
+in the style of \fBps\fP (1).  \fBpvdisplay --columns\fP is the equivalent
+of calling \fBpvs\fP.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 6bd693f..b6941f9 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -3,6 +3,7 @@
 pvs \- report information about physical volumes
 .SH SYNOPSIS
 .B pvs
+[\-a|\-\-all]
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
@@ -18,6 +19,9 @@ pvs produces formatted output about physical volumes.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.I \-\-all
+Process all devices, even ones without an LVM label.
+.TP
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
diff --git a/man/vgs.8.in b/man/vgs.8.in
index b9abaa8..55f679c 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -3,6 +3,7 @@
 vgs \- report information about volume groups
 .SH SYNOPSIS
 .B vgs
+[\-a|\-\-all]
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
@@ -18,6 +19,9 @@ vgs produces formatted output about volume groups.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.I \-\-all
+Process all volume groups.  Equivalent to not specifying any volume groups.
+.TP
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
-- 
1.6.0.6


