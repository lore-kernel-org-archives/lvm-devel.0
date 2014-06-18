From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 18 Jun 2014 11:49:12 +0000 (UTC)
Subject: master - man: add man page entry for dmsetup info -c -S/--select + minor cleanups
Message-ID: <20140618114912.1619561038@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc6e2a703b604ea5c69f7ea2e00a871c70514b73
Commit:        fc6e2a703b604ea5c69f7ea2e00a871c70514b73
Parent:        0548a82e630dc0bf24943ec49a15b86834268b57
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 18 13:48:27 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 18 13:48:27 2014 +0200

man: add man page entry for dmsetup info -c -S/--select + minor cleanups

---
 man/dmsetup.8.in |   12 ++++++++++++
 man/lvs.8.in     |    8 ++++----
 man/pvs.8.in     |    8 ++++----
 man/vgs.8.in     |    8 ++++----
 4 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 10c63ab..b545dcf 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -40,6 +40,8 @@ dmsetup \(em low level logical volume management
 .IR fields ]
 .RB [ \-O | \-\-sort
 .IR sort_fields ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RI [ device_name ]
 .RE
 .br
@@ -244,6 +246,16 @@ The value \fInone\fP is equivalent to specifying zero.
 .BR \-r | \-\-readonly
 Set the table being loaded read-only.
 .TP
+.BR \-S | \-\-select \ \fISelection
+Display only rows that match Selection criteria. All rows are displayed
+with the additional "selected" column (-o selected) showing 1 if the row
+matches the Selection and 0 otherwise. The Selection criteria are defined
+by specifying column names and their valid values while making use of
+supported comparison operators. As a quick help and to see full list of
+column names that can be used in Selection and the set of supported
+selection operators, check the output of \fBdmsetup info -c -S help\fP
+command.
+.TP
 .IR \fB\-\-table \ < table >
 Specify a one-line table directly on the command line.
 .TP
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 371aaf6..1afd63d 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -198,14 +198,14 @@ selection. Precede any column with '\fI\-\fP' for a reverse sort on that column.
 Output columns as rows.
 .TP
 .BR  \-S ", " \-\-select " " \fISelection
-Display only rows that match selection criteria. All rows are displayed with
+Display only rows that match Selection criteria. All rows are displayed with
 the additional "selected" column (\fB-o selected\fP) showing 1 if the row
-matches the Selection and 0 otherwise. The selection criteria are defined
+matches the Selection and 0 otherwise. The Selection criteria are defined
 by specifying column names and their valid values (that can include reserved
 values) while making use of supported comparison operators. See \fBlvm\fP(8)
 and \fB\-S\fP, \fB\-\-select\fP description for more detailed information
-about constructing the selection criteria. As a quick help and to see full
-list of columns names that can be used in selection including the list of
+about constructing the Selection criteria. As a quick help and to see full
+list of column names that can be used in Selection including the list of
 reserved values and the set of supported selection operators, check the
 output of \fBlvs -S help\fP command.
 .TP
diff --git a/man/pvs.8.in b/man/pvs.8.in
index ea32d78..ccd84a5 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -82,14 +82,14 @@ Physical Volume, showing the start (pvseg_start) and length (pvseg_size) in
 units of physical extents.
 .TP
 .BR  \-S ", " \-\-select " " \fISelection
-Display only rows that match selection criteria. All rows are displayed with
+Display only rows that match Selection criteria. All rows are displayed with
 the additional "selected" column (\fB-o selected\fP) showing 1 if the row
-matches the Selection and 0 otherwise. The selection criteria are defined
+matches the Selection and 0 otherwise. The Selection criteria are defined
 by specifying column names and their valid values (that can include reserved
 values) while making use of supported comparison operators. See \fBlvm\fP(8)
 and \fB\-S\fP, \fB\-\-select\fP description for more detailed information
-about constructing the selection criteria. As a quick help and to see full
-list of columns names that can be used in selection including the list of
+about constructing the Selection criteria. As a quick help and to see full
+list of column names that can be used in Selection including the list of
 reserved values and the set of supported selection operators, check the
 output of \fBpvs -S help\fP command.
 .TP
diff --git a/man/vgs.8.in b/man/vgs.8.in
index 2f71d26..2d4946f 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -99,14 +99,14 @@ column.
 Output columns as rows.
 .TP
 .BR  \-S ", " \-\-select " " \fISelection
-Display only rows that match selection criteria. All rows are displayed with
+Display only rows that match Selection criteria. All rows are displayed with
 the additional "selected" column (\fB-o selected\fP) showing 1 if the row
-matches the Selection and 0 otherwise. The selection criteria are defined
+matches the Selection and 0 otherwise. The Selection criteria are defined
 by specifying column names and their valid values (that can include reserved
 values) while making use of supported comparison operators. See \fBlvm\fP(8)
 and \fB\-S\fP, \fB\-\-select\fP description for more detailed information
-about constructing the selection criteria. As a quick help and to see full
-list of columns names that can be used in selection including the list of
+about constructing the Selection criteria. As a quick help and to see full
+list of column names that can be used in Selection including the list of
 reserved values and the set of supported selection operators, check the
 output of \fBvgs -S help\fP command.
 .TP


