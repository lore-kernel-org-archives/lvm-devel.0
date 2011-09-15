From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Sep 2011 20:01:21 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110915200121.13339.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-09-15 20:01:21

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2111&r2=1.2112

--- LVM2/WHATS_NEW	2011/09/15 15:26:40	1.2111
+++ LVM2/WHATS_NEW	2011/09/15 20:01:21	1.2112
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix rounding direction in lvresize when reducing volume size.
   Fix possible overflow of size if %FREE or %VG is used.
   Fix vgchange activation of snapshot with virtual origin.
   Activate virtual snapshot origin exclusively (only on local node in cluster).


