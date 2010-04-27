From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Apr 2010 13:34:57 -0000
Subject: LVM2/man lvdisplay.8.in
Message-ID: <20100427133457.21743.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-27 13:34:56

Modified files:
	man            : lvdisplay.8.in 

Log message:
	Mention how to get PV to LV mappings.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvdisplay.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/man/lvdisplay.8.in	2009/10/26 14:37:09	1.3
+++ LVM2/man/lvdisplay.8.in	2010/04/27 13:34:56	1.4
@@ -76,7 +76,10 @@
 .TP
 .I \-m, \-\-maps
 Display the mapping of logical extents to physical volumes and
-physical extents.
+physical extents.  To map physical extents
+to logical extents use
+.BR
+\fBpvs --segments -o+lv_name,seg_start_pe,segtype\fP.
 .TP
 .I \-\-columns | \-C
 Display output in columns, the equivalent of \fBlvs\fP.  Options listed
@@ -95,4 +98,5 @@
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvcreate (8), 
-.BR lvscan (8)
+.BR lvscan (8),
+.BR pvs (8)


