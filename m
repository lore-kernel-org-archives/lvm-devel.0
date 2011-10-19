From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Oct 2011 16:45:36 -0000
Subject: LVM2/man lvm.8.in
Message-ID: <20111019164536.3216.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-19 16:45:35

Modified files:
	man            : lvm.8.in 

Log message:
	Add few more protected names

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/man/lvm.8.in	2010/11/17 10:19:30	1.6
+++ LVM2/man/lvm.8.in	2011/10/19 16:45:35	1.7
@@ -275,7 +275,8 @@
 VG and LV names cannot begin with a hyphen.
 There are also various reserved names that are used internally by lvm that can not be used as LV or VG names.
 A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
-A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain the strings '_mlog' or '_mimage'
+A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain
+the strings '_mlog', '_mimage', '_tmeta', '_tpool'.
 
 
 .SH DIAGNOSTICS


