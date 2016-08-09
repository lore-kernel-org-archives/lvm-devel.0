From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:40:04 +0000 (UTC)
Subject: master - man: add lvm fullreport man page
Message-ID: <20160809174004.B63ED6078D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6fcfa2855ba89f2516a22265a8ed1a70fd841aff
Commit:        6fcfa2855ba89f2516a22265a8ed1a70fd841aff
Parent:        5ac008116be94797f7f9f39d61cb1bd96c60669c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 9 17:53:32 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:49:11 2016 +0200

man: add lvm fullreport man page

---
 man/Makefile.in         |    2 +-
 man/lvm-fullreport.8.in |  145 +++++++++++++++++++++++++++++++++++++++++++++++
 man/lvm.8.in            |    4 +
 3 files changed, 150 insertions(+), 1 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 2e0fd95..b923a9a 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -30,7 +30,7 @@ LVMDBUSDMAN = lvmdbusd.8
 
 MAN5=lvm.conf.5
 MAN7=lvmsystemid.7
-MAN8=lvm-config.8 lvm-dumpconfig.8 lvm-lvpoll.8 \
+MAN8=lvm-config.8 lvm-dumpconfig.8 lvm-fullreport.8 lvm-lvpoll.8 \
 	lvchange.8 lvmconfig.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 \
 	lvm.8 lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \
 	lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
diff --git a/man/lvm-fullreport.8.in b/man/lvm-fullreport.8.in
new file mode 100644
index 0000000..96ac937
--- /dev/null
+++ b/man/lvm-fullreport.8.in
@@ -0,0 +1,145 @@
+.TH LVM-FULLREPORT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc" \" -*- nroff -*-
+.SH NAME
+lvm fullreport \(em Report information about PVs, PV segments, VGs, LVs and LV segments, all at once for each VG.
+.SH SYNOPSIS
+.B lvm fullreport
+.RB [ \-a | \-\-all ]
+.RB [ \-\-aligned ]
+.RB [ \-\-binary ]
+.RB [ \-\-commandprofile
+.IR ProfileName ]
+.RB [[ \-\-configreport
+.IR ReportName ]
+.RB [ \-o | \-\-options
+.RI [ + | \- | # ] Field1 [, Field2 ...]
+.RB [ \-O | \-\-sort
+.RI [ + | \- ] Key1 [, Key2 ...]]
+.RB [ \-S | \-\-select
+.IR Selection ]
+.RB ...]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-ignoreskippedcluster ]
+.RB [ \-\-logonly ]
+.RB [ \-\-nameprefixes ]
+.RB [ \-\-noheadings ]
+.RB [ \-\-nosuffix ]
+.RB [ \-P | \-\-partial ]
+.RB [ \-\-reportformat
+.RB { basic | json }]
+.RB [ \-\-rows ]
+.RB [ \-\-separator
+.IR Separator ]
+.RB [ \-\-unbuffered ]
+.RB [ \-\-units
+.IR hHbBsSkKmMgGtTpPeE ]
+.RB [ \-\-unquoted ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.RI [ VolumeGroupName
+.RI [ VolumeGroupName ...]]
+.SH DESCRIPTION
+lvm fullreport produces formatted output about PVs, PV segments, VGs, LVs 
+and LV segments, all at once for each VG and guarded by per-VG lock
+for consistency.
+.SH OPTIONS
+See \fBlvm\fP(8) for common options.
+.TP
+.B \-\-all
+Include information in the output about internal Logical Volumes that
+are components of normally-accessible Logical Volumes, such as mirrors,
+but which are not independently accessible (e.g. not mountable).
+The names of such Logical Volumes are enclosed within square brackets
+in the output.  For example, after creating a mirror using
+.B lvcreate -m1 \-\-mirrorlog disk
+, this option will reveal three internal Logical
+Volumes, with suffixes mimage_0, mimage_1, and mlog.
+.TP
+.B \-\-aligned
+Use with \fB\-\-separator\fP to align the output columns.
+.TP
+.B \-\-binary
+Use binary values "0" or "1" instead of descriptive literal values
+for columns that have exactly two valid values to report (not counting
+the "unknown" value which denotes that the value could not be determined).
+.TP
+.B \-\-configreport  \fI ReportName
+Make any subsequent \fB\-o, \-\-options\fP, \fB\-O, \-\-sort\fP or
+\fB\-S, \-\-select\fP to apply for \fIReportName\fP where \fIReportName\fP
+is 'pv' for PV subreport, 'pvseg' for PV segment subreport, 'vg' for
+VG subreport, 'lv' for LV subreport, 'seg' for LV segment subreport or 'log'
+for log report. If \fB\-\-configreport\fP option is not used to identify a
+report, then all command's subreports are assumed except log report. The log
+report is available only if enabled by \fBlog/report_command_log\fP
+\fBlvm.conf\fP(5) setting or if \fB\-\-logonly\fP option is used.
+.TP
+.B \-\-logonly
+Suppress the main report itself and display only log report on output.
+.TP
+.B \-\-nameprefixes
+Add an "LVM2_" prefix plus the field name to the output.  Useful
+with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
+be used to set environment variables (for example, in \fBudev\fP(7) rules).
+.TP
+.B \-\-noheadings
+Suppress the headings line that is normally the first line of output.
+Useful if grepping the output.
+.TP
+.B \-\-nosuffix
+Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
+(except h and H) if processing the output.
+.TP
+.BR \-o ", " \-\-options
+Comma-separated ordered list of columns.
+.IP
+Precede the list with '\fI+\fP' to append to the current list
+of columns, '\fI-\fP' to remove from the current list of columns
+or '\fI#\fP' to compact given columns. The \fI\-o\fP option can
+be repeated, providing several lists. These lists are evaluated
+from left to right.
+.IP
+For the list of columns, see \fBpvs\fP(8), \fBvgs\fP(8),
+\fBlvs\fP(8) man page or check \fBpvs\fP, \fBvgs\fP, \fBlvs -o help\fP
+output.
+.TP
+.BR \-O ", " \-\-sort
+Comma-separated ordered list of columns to sort by.  Replaces the default
+selection. Precede any column with '\fI\-\fP' for a reverse sort on that
+column.
+.TP
+.B \-\-rows
+Output columns as rows.
+.TP
+.BR  \-S ", " \-\-select " " \fISelection
+Display only rows that match Selection criteria. All rows are displayed with
+the additional "selected" column (\fB-o selected\fP) showing 1 if the row
+matches the Selection and 0 otherwise. The Selection criteria are defined
+by specifying column names and their valid values (that can include reserved
+values) while making use of supported comparison operators. See \fBlvm\fP(8)
+and \fB\-S\fP, \fB\-\-select\fP description for more detailed information
+about constructing the Selection criteria. As a quick help and to see full
+list of column names that can be used in Selection including the list of
+reserved values and the set of supported selection operators, check the
+output of \fBpvs\fP, \fBvgs\fP, \fBlvs -S help\fP command.
+.TP
+.B \-\-separator \fISeparator
+String to use to separate each column.  Useful if grepping the output.
+.TP
+.B \-\-unbuffered
+Produce output immediately without sorting or aligning the columns properly.
+.TP
+.B \-\-units \fIhHbBsSkKmMgGtTpPeE
+All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
+(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  
+Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify 
+custom units e.g. \-\-units 3M
+.TP
+.B \-\-unquoted
+When used with \fB\-\-nameprefixes\fP, output values in the field=value
+pairs are not quoted.
+.SH SEE ALSO
+.BR lvm (8),
+.BR pvs (8),
+.BR vgs (8),
+.BR lvs (8)
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 76d05fd..da85349 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -65,6 +65,10 @@ The same as \fBlvmconfig\fP(8) below.
 .B formats
 Display recognised metadata formats.
 .TP
+.B fullreport
+Report information about PVs, PV segments, VGs, LVs and LV segments,
+all at once.
+.TP
 .B help
 Display the help text.
 .TP


