From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 20 Jan 2009 11:25:51 -0500
Subject: [PATCH 2/2] Add --rows option to pvs, vgs, lvs man pages.
In-Reply-To: <1232468751-6028-1-git-send-email-dwysocha@redhat.com>
References: <1232468751-6028-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1232468751-6028-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/lvs.8.in |    5 ++++-
 man/pvs.8.in |    4 ++++
 man/vgs.8.in |    5 ++++-
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/man/lvs.8.in b/man/lvs.8.in
index 934a89e..fa27fe5 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -7,7 +7,7 @@ lvs \- report information about logical volumes
 [\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
-[\-P|\-\-partial] [\-\-segments]
+[\-P|\-\-partial] [\-\-rows] [\-\-segments]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
 [\-v|\-\-verbose] 
@@ -75,6 +75,9 @@ Use default columns that emphasize segment information.
 Comma-separated ordered list of columns to sort by.  Replaces the default
 selection. Precede any column with - for a reverse sort on that column.
 .TP
+.I \-\-rows
+Output columns as rows.
+.TP
 .I \-\-separator Separator
 String to use to separate each column.  Useful if grepping the output.
 .TP
diff --git a/man/pvs.8.in b/man/pvs.8.in
index a78218e..667f07a 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -7,6 +7,7 @@ pvs \- report information about physical volumes
 [\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
+[\-\-rows]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
 [\-v|\-\-verbose] 
@@ -51,6 +52,9 @@ units of physical extents.
 Comma-separated ordered list of columns to sort by.  Replaces the default
 selection. Precede any column with - for a reverse sort on that column.
 .TP
+.I \-\-rows
+Output columns as rows.
+.TP
 .I \-\-separator Separator
 String to use to separate each column.  Useful if grepping the output.
 .TP
diff --git a/man/vgs.8.in b/man/vgs.8.in
index b3fed28..2a4d36b 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -7,7 +7,7 @@ vgs \- report information about volume groups
 [\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
-[\-P|\-\-partial]
+[\-P|\-\-partial] [\-\-rows]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
 [\-v|\-\-verbose] 
@@ -63,6 +63,9 @@ Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere, (i)nherited
 Comma-separated ordered list of columns to sort by.  Replaces the default
 selection. Precede any column with - for a reverse sort on that column.
 .TP
+.I \-\-rows
+Output columns as rows.
+.TP
 .I \-\-separator Separator
 String to use to separate each column.  Useful if grepping the output.
 .TP
-- 
1.6.0.5


