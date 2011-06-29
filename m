From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jun 2011 14:56:34 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/pv.c man/pvs.8.in
Message-ID: <20110629145634.14337.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-29 14:56:33

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : pv.c 
	man            : pvs.8.in 

Log message:
	Append 'm' attribute to pv_attr for missing PVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2029&r2=1.2030
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2011/06/28 13:42:15	1.2029
+++ LVM2/WHATS_NEW	2011/06/29 14:56:33	1.2030
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Append 'm' attribute to pv_attr for missing PVs.
   Annotate CLVMD_CMD_SYNC_NAMES in decode_cmd.
   Remove enforcement of udev verification when using non-standard /dev location.
   Fix to preserve exclusive activation of mirror while up-converting.
--- LVM2/lib/metadata/pv.c	2011/02/21 12:33:16	1.9
+++ LVM2/lib/metadata/pv.c	2011/06/29 14:56:33	1.10
@@ -197,6 +197,7 @@
 
 	repstr[0] = (pv->status & ALLOCATABLE_PV) ? 'a' : '-';
 	repstr[1] = (pv->status & EXPORTED_VG) ? 'x' : '-';
+	repstr[2] = (pv->status & MISSING_PV) ? 'm' : '-';
 	return repstr;
 }
 
--- LVM2/man/pvs.8.in	2010/06/28 20:34:12	1.13
+++ LVM2/man/pvs.8.in	2011/06/29 14:56:33	1.14
@@ -59,7 +59,7 @@
 .IP
 With --segments, any "pvseg_" prefixes are optional; otherwise any
 "pv_" prefixes are optional.  Columns mentioned in \fBvgs (8)\fP can also
-be chosen. The pv_attr bits are: (a)llocatable and e(x)ported.
+be chosen. The pv_attr bits are: (a)llocatable, e(x)ported and (m)issing.
 .TP
 .I \-\-segments
 Produces one line of output for each contiguous allocation of space on each


