From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Feb 2009 01:47:03 -0000
Subject: LVM2 ./WHATS_NEW man/lvm.8.in
Message-ID: <20090220014703.31706.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-02-20 01:47:02

Modified files:
	.              : WHATS_NEW 
	man            : lvm.8.in 

Log message:
	Mention the restriction on file descriptors at invocation on the lvm man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1044&r2=1.1045
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2009/02/17 18:56:41	1.1044
+++ LVM2/WHATS_NEW	2009/02/20 01:47:02	1.1045
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Mention the restriction on file descriptors at invocation on the lvm man page.
   Index cached vgmetadata by vgid not vgname to cope with duplicate vgnames.
   No longer require kernel and metadata major numbers to match.
   Add a fully-functional get_cluster_name() to clvmd corosync interface.
--- LVM2/man/lvm.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvm.8.in	2009/02/20 01:47:02	1.2
@@ -18,6 +18,10 @@
 LVM command (for example by using a hard or soft link) it acts as 
 that command.  
 .LP
+On invocation, \fBlvm\fP requires that only the standard file descriptors
+stdin, stdout and stderr are available.  If others are found, they
+get closed and messages are issued warning about the leak.
+.LP
 Where commands take VG or LV names as arguments, the full path name is
 optional.  An LV called "lvol0" in a VG called "vg0" can be specified
 as "vg0/lvol0".  Where a list of VGs is required but is left empty, 


