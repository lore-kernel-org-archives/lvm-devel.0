From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:45 +0000 (UTC)
Subject: master - report: select: add man pages for report selection feature
Message-ID: <20140617143445.8974560C4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94316dfe9d61a7b46c88458e4a8232667fde192a
Commit:        94316dfe9d61a7b46c88458e4a8232667fde192a
Parent:        40e0f444955690d4c5a5c5da8320a65e23a50553
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 16 16:23:55 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:21 2014 +0200

report: select: add man pages for report selection feature

---
 man/lvdisplay.8.in |    2 +
 man/lvm.8.in       |   69 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 man/lvs.8.in       |   14 ++++++++++
 man/pvdisplay.8.in |    2 +
 man/pvs.8.in       |   14 ++++++++++
 man/vgdisplay.8.in |    2 +
 man/vgs.8.in       |   14 ++++++++++
 7 files changed, 117 insertions(+), 0 deletions(-)

diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index 5593752..1283d58 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -40,6 +40,8 @@ lvdisplay \(em display attributes of a logical volume
 .RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
 .RB [ \-\-segments ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-unbuffered ]
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 5449e20..0a5c69c 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -207,6 +207,13 @@ changed with this option. To insert a replacement Physical Volume
 of the same or large size use \fBpvcreate \-u\fP to set the uuid to
 match the original followed by \fBvgcfgrestore\fP(8).
 .TP
+.BR \-S ", " \-\-select " " \fISelection
+For reporting commands, display only rows that match selection criteria.
+All rows are displayed with the additional "selected" column (\fB-o selected\fP)
+showing 1 if the row matches the Selection and 0 otherwise.
+See \fBSELECTION CRITERIA\fP section of this man page for more
+information about the way the selection criteria are constructed.
+.TP
 .BR \-M ", " \-\-metadatatype " " \fIType
 Specifies which type of on-disk metadata to use, such as \fIlvm1\fP
 or \fIlvm2\fP, which can be abbreviated to \fI1\fP or \fI2\fP respectively.
@@ -419,6 +426,68 @@ volume types are an example of this.  Other logical volume types may
 require more than one command to create.  The cache (\fBlvmcache\fP(7))
 and thin provisioning (\fBlvmthin\fP(7)) types are examples of this.
 
+.SH SELECTION CRITERIA
+.LP
+The selection criteria are a set of \fBstatements\fP combined by \fBlogical
+and grouping operators\fP. The \fBstatement\fP consists of \fBcolumn\fP
+name for which a set of valid \fBvalues\fP is defined using
+\fBcomparison operators\fP. For complete list of column names (fields)
+that can be used in selection, see the output of \fB<lvm reporting command> -S help\fP.
+.LP
+\fBComparison operators\fP (cmp_op):
+.IP
+\fB=~\fP \(em Matching regular expression.
+.IP
+\fB!~\fP \(em Not matching regular expression.
+.IP
+\fB=\fP  \(em Equal to.
+.IP
+\fB!=\fP \(em Not equal to.
+.IP
+\fB>=\fP \(em Greater than or equal to.
+.IP
+\fB>\fP  \(em Greater than
+.IP
+\fB<=\fP \(em Less than or equal to.
+.IP
+\fB<\fP  \(em Less than.
+.LP
+\fBBinary logical operators\fP (cmp_log):
+.IP
+\fB&&\fP \(em All fields must match
+.IP
+\fB,\fP  \(em All fields must match
+.IP
+\fB||\fP \(em At least one field must match
+.IP
+\fB#\fP  \(em At least one field must match
+.LP
+\fBUnary logical operators\fP:
+.IP
+\fB!\fP  \(em Logical negation
+.LP
+\fBGrouping operators\fP:
+.IP
+\fB(\fP  \(em Left parenthesis
+.IP
+\fB)\fP  \(em Right parenthesis
+.IP
+\fB[\fP  \(em List start
+.IP
+\fB]\fP  \(em List end
+.LP
+\fBInformal grammar specification\fP:
+.IP
+.BR STATEMENT " = " column " cmp_op " VALUE " | " STATEMENT " log_op " STATEMENT " | " (STATEMENT) " | " !(STATEMENT)
+.IP
+.BR VALUE " = " [VALUE " log_op " VALUE]
+.br
+For list-based types: string list. The log_op must always be of one type within the whole list value.
+.IP
+.BR VALUE " = " value
+.br
+For scalar types: number (integer), size (floating point number with size unit suffix), percent (floating point number with or without % suffix), string.
+
 .SH DIAGNOSTICS
 All tools return a status code of zero on success or non-zero on failure.
 .SH FILES
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 2467306..371aaf6 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -20,6 +20,8 @@ lvs \(em report information about logical volumes
 .RI [ + | \- ] Key1 [,[ + | \- ] Key2 [,...]]]
 .RB [ \-P | \-\-partial ]
 .RB [ \-\-rows ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-segments ]
@@ -195,6 +197,18 @@ selection. Precede any column with '\fI\-\fP' for a reverse sort on that column.
 .B \-\-rows
 Output columns as rows.
 .TP
+.BR  \-S ", " \-\-select " " \fISelection
+Display only rows that match selection criteria. All rows are displayed with
+the additional "selected" column (\fB-o selected\fP) showing 1 if the row
+matches the Selection and 0 otherwise. The selection criteria are defined
+by specifying column names and their valid values (that can include reserved
+values) while making use of supported comparison operators. See \fBlvm\fP(8)
+and \fB\-S\fP, \fB\-\-select\fP description for more detailed information
+about constructing the selection criteria. As a quick help and to see full
+list of columns names that can be used in selection including the list of
+reserved values and the set of supported selection operators, check the
+output of \fBlvs -S help\fP command.
+.TP
 .B \-\-segments
 Use default columns that emphasize segment information.
 .TP
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index aab65ca..0399c1e 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -39,6 +39,8 @@ pvdisplay \- display attributes of a physical volume
 .RB [ \-O | \-\-sort
 .RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...
 .RI ]]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-unbuffered ]
diff --git a/man/pvs.8.in b/man/pvs.8.in
index ed57980..ea32d78 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -21,6 +21,8 @@ pvs \(em report information about physical volumes
 .RB [ \-P | \-\-partial ]
 .RB [ \-\-rows ]
 .RB [ \-\-segments ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-unbuffered ]
@@ -79,6 +81,18 @@ Produces one line of output for each contiguous allocation of space on each
 Physical Volume, showing the start (pvseg_start) and length (pvseg_size) in
 units of physical extents.
 .TP
+.BR  \-S ", " \-\-select " " \fISelection
+Display only rows that match selection criteria. All rows are displayed with
+the additional "selected" column (\fB-o selected\fP) showing 1 if the row
+matches the Selection and 0 otherwise. The selection criteria are defined
+by specifying column names and their valid values (that can include reserved
+values) while making use of supported comparison operators. See \fBlvm\fP(8)
+and \fB\-S\fP, \fB\-\-select\fP description for more detailed information
+about constructing the selection criteria. As a quick help and to see full
+list of columns names that can be used in selection including the list of
+reserved values and the set of supported selection operators, check the
+output of \fBpvs -S help\fP command.
+.TP
 .BR \-O ", " \-\-sort
 Comma-separated ordered list of columns to sort by.  Replaces the default
 selection. Precede any column with '\fI\-\fP' for a reverse sort on that
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index d1ea89a..97cb314 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -39,6 +39,8 @@ vgdisplay \(em display attributes of volume groups
 .RB [ \-O | \-\-sort
 .RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-unbuffered ]
diff --git a/man/vgs.8.in b/man/vgs.8.in
index b389ea2..2f71d26 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -20,6 +20,8 @@ vgs \(em report information about volume groups
 .RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
 .RB [ \-P | \-\-partial ]
 .RB [ \-\-rows ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RB [ \-\-separator
 .IR Separator ]
 .RB [ \-\-unbuffered ]
@@ -96,6 +98,18 @@ column.
 .B \-\-rows
 Output columns as rows.
 .TP
+.BR  \-S ", " \-\-select " " \fISelection
+Display only rows that match selection criteria. All rows are displayed with
+the additional "selected" column (\fB-o selected\fP) showing 1 if the row
+matches the Selection and 0 otherwise. The selection criteria are defined
+by specifying column names and their valid values (that can include reserved
+values) while making use of supported comparison operators. See \fBlvm\fP(8)
+and \fB\-S\fP, \fB\-\-select\fP description for more detailed information
+about constructing the selection criteria. As a quick help and to see full
+list of columns names that can be used in selection including the list of
+reserved values and the set of supported selection operators, check the
+output of \fBvgs -S help\fP command.
+.TP
 .B \-\-separator \fISeparator
 String to use to separate each column.  Useful if grepping the output.
 .TP


