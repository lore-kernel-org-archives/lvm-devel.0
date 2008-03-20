From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Mar 2008 18:34:29 -0000
Subject: LVM2/man lvm.8
Message-ID: <20080320183429.11931.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-20 18:34:29

Modified files:
	man            : lvm.8 

Log message:
	Add LV and VG name restrictions to the lvm man page.
	
	Original patch by: Gerrard Geldenhuis <Gerrard.Geldenhuis@datacash.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/man/lvm.8	2008/01/11 20:24:25	1.12
+++ LVM2/man/lvm.8	2008/03/20 18:34:29	1.13
@@ -257,6 +257,16 @@
 The volume group name that is assumed for 
 any reference to a logical volume that doesn't specify a path.
 Not set by default.
+.SH VALID NAMES
+The following characters are valid for VG and LV names:
+\fBa-z A-Z 0-9 + _ . -\fP
+.LP
+VG and LV names cannot begin with a hyphen.
+There are also various reserved names that are used internally by lvm that can not be used as LV or VG names.
+A VG cannot be called anything that exists in /dev/ at the time of creation, nor can it be called '.' or '..'.
+A LV cannot be called '.' '..' 'snapshot' or 'pvmove'. The LV name may also not contain the strings '_mlog' or '_mimage'
+
+
 .SH DIAGNOSTICS
 All tools return a status code of zero on success or non-zero on failure.
 .SH FILES


