From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 30 Mar 2014 21:46:00 +0000 (UTC)
Subject: master - man: sort options
Message-ID: <20140330214600.2D8D8602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31d68b7124519b4ed6b9ba1960cb021962f2a3dd
Commit:        31d68b7124519b4ed6b9ba1960cb021962f2a3dd
Parent:        7a9c569eb41f48b32c32dd29f8f36add09e95e30
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 30 22:35:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 30 23:43:31 2014 +0200

man: sort options

Sort order for -C|--columns as with other options,
and use short capital name as the first (as with other options).
Also drop multiple reference for pvs/lvs/vgs, since now
the text for -C is really close to referrence of lvm anyway.
---
 WHATS_NEW          |    1 +
 man/lvdisplay.8.in |   10 +++++-----
 man/pvdisplay.8.in |   15 +++++++--------
 man/vgdisplay.8.in |   13 ++++++-------
 4 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3368c9d..0decc72 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Update man pages for pv/vg/lvdisplay.
   Report error when running pvscan with free argument (i.e. PV name).
   Fix error message for pvdisplay -c -m and add new for pvdisplay -c -s.
   Return proper invalid cmd when vgimport/exports find error in parameters.
diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index 49654bc..8348879 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -21,7 +21,7 @@ lvdisplay \- display attributes of a logical volume
 .br
 
 .B lvdisplay
-.BR \-\-columns | \-C
+.BR \-C | \-\-columns
 .RB [ \-\-aligned ]
 .RB [ \-a | \-\-all ]
 .RB [ \-d | \-\-debug ]
@@ -66,6 +66,10 @@ For example, after creating a mirror using
 this option will reveal three internal Logical Volumes, with suffixes
 mimage_0, mimage_1, and mlog.
 .TP
+.BR \-C ", " \-\-columns
+Display output in columns, the equivalent of \fBlvs\fP(8).
+Options listed are the same as options given in \fBlvs\fP(8).
+.TP
 .BR \-c ", " \-\-colon
 Generate colon separated output for easier parsing in scripts or programs.
 N.B. \fBlvs\fP(8) provides considerably more control over the output.
@@ -94,10 +98,6 @@ Display the mapping of logical extents to physical volumes and
 physical extents.  To map physical extents
 to logical extents use:
 .B pvs \-\-segments \-o+lv_name,seg_start_pe,segtype
-.TP
-.BR \-\-columns ", " \-C
-Display output in columns, the equivalent of \fBlvs\fP. Options listed
-are the same as options given in \fBlvs\fP(8).
 .SH Examples
 Shows attributes of that logical volume. If snapshot
 logical volumes have been created for this original logical volume,
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index 13c26b5..b2a2577 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -22,7 +22,7 @@ pvdisplay \- display attributes of a physical volume
 
 .br
 .B pvdisplay
-.BR \-\-columns | \-C
+.BR \-C | \-\-columns
 .RB [ \-\-aligned ]
 .RB [ \-a | \-\-all ]
 .RB [ \-d | \-\-debug ]
@@ -53,8 +53,12 @@ area and so on.
 \fBpvs\fP(8) is an alternative that provides the same information 
 in the style of \fBps\fP(1).
 .SH OPTIONS
-See \fBlvm\fP for common options and \fBpvs\fP for options given with
-\fB\-\-columns\fP.
+See \fBlvm\fP(8) for common options.
+.TP
+.BR \-C ", " \-\-columns
+Display output in columns, the equivalent of \fBpvs\fP(8).  See
+\fBpvs\fP(8) for a description of other options with this form of
+\fBpvdisplay\fP.
 .TP
 .BR \-c ", " \-\-colon
 Generate colon separated output for easier parsing in scripts or programs.
@@ -83,11 +87,6 @@ Only display the size of the given physical volumes.
 .BR \-m ", " \-\-maps
 Display the mapping of physical extents to logical volumes and
 logical extents.
-.TP
-.BR \-\-columns ", " \-C
-Display output in columns, the equivalent of \fBpvs\fP(8).  See
-\fBpvs\fP(8) for a description of other options with this form of
-\fBpvdisplay\fP.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvs (8),
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index 4dada16..7f50f83 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -22,7 +22,7 @@ vgdisplay \- display attributes of volume groups
 
 .br
 .B vgdisplay
-.BR \-\-columns | \-C
+.BR \-C | \-\-columns
 .RB [ \-\-aligned ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
@@ -53,13 +53,16 @@ volumes and their sizes etc.
 \fBvgs\fP(8) is an alternative that provides the same information
 in the style of \fBps\fP(1).
 .SH OPTIONS
-See \fBlvm\fP(8) for common options and \fBvgs\fP(8) for options given with
-\fB\-\-columns\fP.
+See \fBlvm\fP(8) for common options.
 .TP
 .BR \-A ", " \-\-activevolumegroups
 Only select the active volume groups. The volume group is considered active
 if at least one of its logical volumes is active.
 .TP
+.BR \-C ", " \-\-columns
+Display output in columns, the equivalent of \fBvgs\fP(8). 
+Options listed are the same as options given in \fPvgs\fP(8).
+.TP
 .BR \-c ", " \-\-colon
 Generate colon separated output for easier parsing in scripts or programs.
 N.B. \fBvgs\fP(8) provides considerably more control over the output.
@@ -97,10 +100,6 @@ information of vgdisplay's activities.
 .TP
 .B \-\-version
 Display version and exit successfully.
-.TP
-.BR \-\-columns | \-C
-Display output in columns, the equivalent of \fBvgs\fP(8). 
-Options listed are the same as options given in \fPvgs\fP(8).
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgs (8),


