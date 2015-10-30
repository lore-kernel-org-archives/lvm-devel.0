From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:40 +0000 (UTC)
Subject: master - man: pvs/vgs/lvs and -o+, -o-, -o#
Message-ID: <20151030145240.C404A609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f125c1116df74d23b442304d8109a784f677251
Commit:        7f125c1116df74d23b442304d8109a784f677251
Parent:        5b04eda93f903d25e25385d148d28b8cfa1157ea
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 30 15:36:35 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:56 2015 +0100

man: pvs/vgs/lvs and -o+, -o-, -o#

---
 man/lvdisplay.8.in |    2 +-
 man/lvs.8.in       |   11 ++++++++---
 man/pvdisplay.8.in |    2 +-
 man/pvs.8.in       |   11 ++++++++---
 man/vgdisplay.8.in |    2 +-
 man/vgs.8.in       |   11 ++++++++---
 6 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index ed1d3f7..f14fa03 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -37,7 +37,7 @@ lvdisplay \(em display attributes of a logical volume
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
 .RB [ \-o | \-\-options
-.RI [ + ] Field [ ,Field ...]]
+.RI [ + | \- | # ] Field [ ,Field ...]]
 .RB [ \-O | \-\-sort
 .RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 3cb2ec0..952b6ec 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -16,7 +16,7 @@ lvs \(em report information about logical volumes
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
 .RB [ \-o | \-\-options
-.RI [ + ] Field [, Field ]]
+.RI [ + | \- | # ] Field [, Field ]]
 .RB [ \-O | \-\-sort
 .RI [ + | \- ] Key1 [,[ + | \- ] Key2 [,...]]]
 .RB [ \-P | \-\-partial ]
@@ -76,8 +76,13 @@ Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
 (except h and H) if processing the output.
 .TP
 .BR \-o ", " \-\-options
-Comma-separated ordered list of columns.  Precede the list with '\fI+\fP'
-to append to the default selection of columns instead of replacing it.
+Comma-separated ordered list of columns.
+.IP
+Precede the list with '\fI+\fP' to append to the current list
+of columns, '\fI-\fP' to remove from the current list of columns
+or '\fI#\fP' to compact given columns. The \fI\-o\fP option can
+be repeated, providing several lists. These lists are evaluated
+from left to right.
 .IP
 Use \fB\-o lv_all\fP to select all logical volume columns,
 and \fB\-o seg_all\fP
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index c1232d6..5f93634 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -37,7 +37,7 @@ pvdisplay \- display attributes of a physical volume
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
 .RB [ \-o | \-\-options
-.RI [ + ] Field [ ,Field ...]]
+.RI [ + | \- | # ] Field [ ,Field ...]]
 .RB [ \-O | \-\-sort
 .RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...
 .RI ]]
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 605b13d..efafbde 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -16,7 +16,7 @@ pvs \(em report information about physical volumes
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
 .RB [ \-o | \-\-options
-.RI [ + ] Field [ ,Field ...]]
+.RI [ + | \- | # ] Field [ ,Field ...]]
 .RB [ \-O | \-\-sort
 .RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
@@ -65,8 +65,13 @@ Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
 (except h and H) if processing the output.
 .TP
 .BR \-o ", " \-\-options
-Comma-separated ordered list of columns.  Precede the list with '\fI+\fP'
-to append to the default selection of columns.
+Comma-separated ordered list of columns.
+.IP
+Precede the list with '\fI+\fP' to append to the current list
+of columns, '\fI-\fP' to remove from the current list of columns
+or '\fI#\fP' to compact given columns. The \fI\-o\fP option can
+be repeated, providing several lists. These lists are evaluated
+from left to right.
 .IP
 Use \fB-o pv_all\fP to select all physical volume columns,
 and \fB-o pvseg_all\fP to select all Physical Volume segment columns.
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index 172dba4..89a7a5a 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -37,7 +37,7 @@ vgdisplay \(em display attributes of volume groups
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
 .RB [ \-o|\-\-options
-.RI [ + ] Field1 [ ,Field2 ...]]
+.RI [ + | \- | # ] Field1 [ ,Field2 ...]]
 .RB [ \-O | \-\-sort
 .RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
diff --git a/man/vgs.8.in b/man/vgs.8.in
index 654e8bb..f219665 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -16,7 +16,7 @@ vgs \(em report information about volume groups
 .RB [ \-\-noheadings ]
 .RB [ \-\-nosuffix ]
 .RB [ \-o | \-\-options
-.RI [ + ] Field1 [ ,Field2 ...]]
+.RI [ + | \- | # ] Field1 [ ,Field2 ...]]
 .RB [ \-O | \-\-sort
 .RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
@@ -63,8 +63,13 @@ Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
 (except h and H) if processing the output.
 .TP
 .BR \-o ", " \-\-options
-Comma-separated ordered list of columns.  Precede the list with '+' to append
-to the default selection of columns.
+Comma-separated ordered list of columns.
+.IP
+Precede the list with '\fI+\fP' to append to the current list
+of columns, '\fI-\fP' to remove from the current list of columns
+or '\fI#\fP' to compact given columns. The \fI\-o\fP option can
+be repeated, providing several lists. These lists are evaluated
+from left to right.
 .IP
 Use \fB\-o vg_all\fP to select all volume group columns.
 .IP


