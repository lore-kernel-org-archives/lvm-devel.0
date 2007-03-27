From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Mar 2007 13:35:35 -0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c man/lvs.8 ...
Message-ID: <20070327133535.28320.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-03-27 14:35:34

Modified files:
	.              : WHATS_NEW 
	lib/report     : report.c 
	man            : lvs.8 vgs.8 

Log message:
	Update lists of attribute characters in man pages.
	Change cling alloc policy attribute character from 'C' to l'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.592&r2=1.593
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2007/03/26 16:10:09	1.592
+++ LVM2/WHATS_NEW	2007/03/27 13:35:33	1.593
@@ -1,5 +1,7 @@
 Version 2.02.25 -
 =================================
+  Update lists of attribute characters in man pages.
+  Change cling alloc policy attribute character from 'C' to l'.
   Fix creation and conversion of mirrors with tags.
   Fix vgsplit for lvm1 format (set and validate VG name in PVs metadata).
   Split metadata areas in vgsplit properly.
--- LVM2/lib/report/report.c	2007/01/29 23:01:18	1.55
+++ LVM2/lib/report/report.c	2007/03/27 13:35:33	1.56
@@ -49,7 +49,7 @@
 	case ALLOC_CONTIGUOUS:
 		return 'c';
 	case ALLOC_CLING:
-		return 'C';
+		return 'l';
 	case ALLOC_NORMAL:
 		return 'n';
 	case ALLOC_ANYWHERE:
--- LVM2/man/lvs.8	2007/01/18 22:33:24	1.5
+++ LVM2/man/lvs.8	2007/03/27 13:35:33	1.6
@@ -51,7 +51,7 @@
 .IP 2 3
 Permissions: (w)riteable, (r)ead-only
 .IP 3 3
-Allocation policy: (c)ontiguous, (n)ormal, (a)nywhere, (i)nherited
+Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere, (i)nherited
 This is capitalised if the volume is currently locked against allocation
 changes, for example during \fBpvmove\fP (8).
 .IP 4 3
--- LVM2/man/vgs.8	2007/01/18 22:33:24	1.4
+++ LVM2/man/vgs.8	2007/03/27 13:35:33	1.5
@@ -36,9 +36,24 @@
 vg_tags.
 Any "vg_" prefixes are optional.  Columns mentioned in either \fBpvs (8)\fP 
 or \fBlvs (8)\fP can also be chosen, but columns cannot be taken from both
-at the same time.  The vg_attr bits are: (w)riteable, (r)eadonly, 
-resi(z)eable, e(x)ported, (p)artial and (c)lustered.
+at the same time.  
 Use \fb-o help\fP to view the full list of fields available.
+.IP
+The vg_attr bits are:
+.RS
+.IP 1 3
+Permissions: (w)riteable, (r)ead-only
+.IP 2 3
+Resi(z)eable
+.IP 3 3
+E(x)ported
+.IP 4 3
+(p)artial
+.IP 5 3
+Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere, (i)nherited
+.IP 6 3
+(c)lustered
+.RE
 .TP
 .I \-O, \-\-sort
 Comma-separated ordered list of columns to sort by.  Replaces the default


