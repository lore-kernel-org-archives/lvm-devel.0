From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Nov 2016 12:22:38 +0000 (UTC)
Subject: master - man: remove duplicate paragraph about selection criteria from lvm(8) man page
Message-ID: <20161122122238.2FF6C60BAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2315743dd3826e880898bf62bb205931da8c1450
Commit:        2315743dd3826e880898bf62bb205931da8c1450
Parent:        0bbf63134974b85096a7949558f5546204a2a135
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Nov 22 13:20:52 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 22 13:20:52 2016 +0100

man: remove duplicate paragraph about selection criteria from lvm(8) man page

The paragraph about selection criteria together with all the related
context is now documented in lvmreport(7) man page completely.
---
 man/lvm.8.in |  105 +--------------------------------------------------------
 1 files changed, 2 insertions(+), 103 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 0db0ee4..f1ffc7a 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -328,7 +328,7 @@ For reporting commands, display only rows that match \fISelection\fP criteria.
 All rows are displayed with the additional "selected" column (\fB-o selected\fP)
 showing 1 if the row matches the \fISelection\fP and 0 otherwise. For non-reporting
 commands which process LVM entities, the selection can be used to match items
-to process. See \fBSELECTION CRITERIA\fP section of this man page for more
+to process. See \fBSelection\fP section in \fBlvmreport\fP(7)  man page for more
 information about the way the selection criteria are constructed.
 .
 .HP
@@ -639,108 +639,6 @@ volume types are an example of this.  Other logical volume types may
 require more than one command to create.  The cache (\fBlvmcache\fP(7))
 and thin provisioning (\fBlvmthin\fP(7)) types are examples of this.
 .
-.SH SELECTION CRITERIA
-.
-The selection criteria are a set of \fBstatements\fP combined by \fBlogical
-and grouping operators\fP. The \fBstatement\fP consists of \fBcolumn\fP
-name for which a set of valid \fBvalues\fP is defined using
-\fBcomparison operators\fP. For complete list of column names (fields)
-that can be used in selection, see the output of \fB<lvm reporting command> -S help\fP.
-.P
-.SS Comparison operators \fR(cmp_op)
-.sp
-.PD 0
-.TP
-.B =~
-Matching regular expression.
-.TP
-.B !~
-Not matching regular expression.
-.TP
-.B =
-Equal to.
-.TP
-.B !=
-Not equal to.
-.TP
-.B >=
-Greater than or equal to.
-.TP
-.B >
-Greater than
-.TP
-.B <=
-Less than or equal to.
-.TP
-.B <
-Less than.
-.PD
-.P
-.SS Binary logical operators \fR(cmp_log)
-.sp
-.PD 0
-.TP
-.B &&
-All fields must match
-.TP
-.B ,
-All fields must match
-.TP
-.B ||
-At least one field must match
-.TP
-.B #
-At least one field must match
-.PD
-.P
-.SS Unary logical operators
-.TP
-.B !
-Logical negation
-.P
-.SS Grouping operators
-.sp
-.PD 0
-.TP
-.B (
-Left parenthesis
-.TP
-.B )
-Right parenthesis
-.TP
-.B [
-List start
-.TP
-.B ]
-List end
-.TP
-.B {
-List subset start
-.TP
-.B }
-List subset end
-.PD
-.SS Informal grammar specification
-.HP
-.BR STATEMENT " = " column " cmp_op " VALUE " | " \%STATEMENT " log_op " STATEMENT " | " \%(STATEMENT) " | " \%!(STATEMENT)
-.br
-.HP
-.BR VALUE " = " [VALUE " log_op " VALUE]
-.br
-For list-based types: string list. Matches strictly.
-The log_op must always be of one type within the whole list value.
-.HP
-.BR VALUE " = " {VALUE " log_op " VALUE}
-.br
-For list-based types: string list. Matches a subset.
-The log_op must always be of one type within the whole list value.
-.HP
-.BR VALUE " = " value
-.br
-For scalar types: number (integer), size (floating point number
-with size unit suffix), percent (floating point number with or
-without % suffix), string.
-.
 .SH DIAGNOSTICS
 .
 All tools return a status code of zero on success or non-zero on failure.
@@ -835,6 +733,7 @@ directly.
 .nh
 .BR lvm.conf (5),
 .BR lvmcache (7),
+.BR lvmreport(7),
 .BR lvmthin (7),
 .BR clvmd (8),
 .BR dmsetup (8),


