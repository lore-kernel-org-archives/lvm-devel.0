From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 20 Jan 2009 11:25:50 -0500
Subject: [PATCH 1/2] Add --nameprefixes to pvs, vgs, lvs man pages.
Message-ID: <1232468751-6028-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/lvs.8.in |    6 +++++-
 man/pvs.8.in |    6 +++++-
 man/vgs.8.in |    6 +++++-
 3 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/man/lvs.8.in b/man/lvs.8.in
index 9819241..934a89e 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -4,7 +4,7 @@ lvs \- report information about logical volumes
 .SH SYNOPSIS
 .B lvs
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
+[\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-P|\-\-partial] [\-\-segments]
@@ -20,6 +20,10 @@ See \fBlvm\fP for common options.
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
+.I \-\-nameprefixes
+Add a "LVM2_" prefix plus the field name to the output.  Useful with
+--noheadings to produce environment variable listing of field=value pairs.
+.TP
 .I \-\-noheadings
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 49810b6..a78218e 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -4,7 +4,7 @@ pvs \- report information about physical volumes
 .SH SYNOPSIS
 .B pvs
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
+[\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-\-separator Separator] [\-\-unbuffered]
@@ -19,6 +19,10 @@ See \fBlvm\fP for common options.
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
+.I \-\-nameprefixes
+Add a "LVM2_" prefix plus the field name to the output.  Useful with
+--noheadings to produce environment variable listing of field=value pairs.
+.TP
 .I \-\-noheadings
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
diff --git a/man/vgs.8.in b/man/vgs.8.in
index 0ae5c7b..b3fed28 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -4,7 +4,7 @@ vgs \- report information about volume groups
 .SH SYNOPSIS
 .B vgs
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
+[\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-P|\-\-partial]
@@ -20,6 +20,10 @@ See \fBlvm\fP for common options.
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
+.I \-\-nameprefixes
+Add a "LVM2_" prefix plus the field name to the output.  Useful with
+--noheadings to produce environment variable listing of field=value pairs.
+.TP
 .I \-\-noheadings
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-- 
1.6.0.5


