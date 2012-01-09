From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 Jan 2012 12:28:48 -0000
Subject: LVM2 ./WHATS_NEW_DM man/dmsetup.8.in
Message-ID: <20120109122848.30047.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-09 12:28:47

Modified files:
	.              : WHATS_NEW_DM 
	man            : dmsetup.8.in 

Log message:
	Improve readahead in dmsetup man page

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.527&r2=1.528
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW_DM	2012/01/09 12:26:14	1.527
+++ LVM2/WHATS_NEW_DM	2012/01/09 12:28:47	1.528
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Improve dmsetup man page about readahead parameter.
   Use sysfs to set/get of read-ahead setting if possible.
   Fix lvm2-monitor init script to use normalized output when using vgs.
   Add test for max length (DM_MAX_TYPE_NAME) of target type name.
--- LVM2/man/dmsetup.8.in	2011/11/30 22:32:37	1.47
+++ LVM2/man/dmsetup.8.in	2012/01/09 12:28:47	1.48
@@ -15,6 +15,8 @@
 .RS
 .IR table_file ]
 .RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
+.RB [ \-\-readahead
+.RI [ \+ ]< sectors >| auto | none ]
 .RE
 .br
 .B dmsetup deps
@@ -85,6 +87,10 @@
 .B dmsetup resume
 .I device_name
 .RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
+.RS
+.RB [ \-\-readahead
+.RI [ \+ ]< sectors >| auto | none ]
+.RE
 .br
 .B dmsetup setgeometry
 .I device_name cyl head sect start
@@ -202,11 +208,11 @@
 .TP
 .IR \fB\-\-readahead \ [ \+ ]< sectors >| auto | none
 Specify read ahead size in units of sectors.
-The default value is "auto" which allows the kernel to choose
-a suitable value automatically.  The + prefix lets you
+The default value is \fIauto\fP which allows the kernel to choose
+a suitable value automatically.  The \fI\+\fP prefix lets you
 specify a minimum value which will not be used if it is
 smaller than the value chosen by the kernel.
-"None" is equivalent to specifying zero.
+The value \fInone\fP is equivalent to specifying zero.
 .TP
 .BR \-r | \-\-readonly
 Set the table being loaded read-only.
@@ -248,6 +254,8 @@
 .RB [ \-\-notable | \-\-table
 .RI < \fItable >| table_file ]
 .RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
+.RB [ \-\-readahead
+.RI [ + ]< sectors >| auto | none ]
 .br
 Creates a device with the given name.
 If table_file or <table> is supplied, the table is loaded and made live.
@@ -402,6 +410,8 @@
 .B resume
 .I device_name
 .RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
+.RB [ \-\-readahead
+.RI [ + ]< sectors >| auto | none ]
 .br
 Un-suspends a device.
 If an inactive table has been loaded, it becomes live.


