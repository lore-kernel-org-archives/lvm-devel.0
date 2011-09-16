From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 Sep 2011 10:02:14 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110916100214.2157.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-09-16 10:02:14

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2112&r2=1.2113

--- LVM2/WHATS_NEW	2011/09/15 20:01:21	1.2112
+++ LVM2/WHATS_NEW	2011/09/16 10:02:14	1.2113
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix overly strict extent-count divisibility requirements for striped mirrors.
   Fix rounding direction in lvresize when reducing volume size.
   Fix possible overflow of size if %FREE or %VG is used.
   Fix vgchange activation of snapshot with virtual origin.


