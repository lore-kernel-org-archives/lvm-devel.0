From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Sep 2011 12:01:48 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110916120148.22509.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-16 12:01:48

Modified files:
	.              : WHATS_NEW 

Log message:
	Update

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2113&r2=1.2114

--- LVM2/WHATS_NEW	2011/09/16 10:02:14	1.2113
+++ LVM2/WHATS_NEW	2011/09/16 12:01:48	1.2114
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Reset LV status when unlinking LV from VG.
   Fix overly strict extent-count divisibility requirements for striped mirrors.
   Fix rounding direction in lvresize when reducing volume size.
   Fix possible overflow of size if %FREE or %VG is used.


