From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 10:39:22 -0000
Subject: LVM2 ./WHATS_NEW man/lvm.8.in
Message-ID: <20120301103922.16292.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 10:39:21

Modified files:
	.              : WHATS_NEW 
	man            : lvm.8.in 

Log message:
	Add _rimage as reserved suffix

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2329&r2=1.2330
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2012/03/01 10:30:48	1.2329
+++ LVM2/WHATS_NEW	2012/03/01 10:39:21	1.2330
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Add _rimage as reserved suffix to lvm.8 man page.
   Improve error logging from mpath filter.
   Check for allocation failure in hold_lock() in clvmd.
   Use set_lv() (wipe initial 4KiB) for non zeroed thin volume.
--- LVM2/man/lvm.8.in	2011/11/03 14:38:37	1.8
+++ LVM2/man/lvm.8.in	2012/03/01 10:39:21	1.9
@@ -276,7 +276,7 @@
 There are also various reserved names that are used internally by lvm that can not be used as LV or VG names.
 A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
 A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain
-the strings '_mlog', '_mimage', '_tdata', '_tmeta'.
+the strings '_mlog', '_mimage', '_rimage', '_tdata', '_tmeta'.
 
 
 .SH DIAGNOSTICS


