From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 9 Aug 2010 14:06:05 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100809140605.12133.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-08-09 14:06:03

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1697&r2=1.1698

--- LVM2/WHATS_NEW	2010/08/06 15:38:32	1.1697
+++ LVM2/WHATS_NEW	2010/08/09 14:06:03	1.1698
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Never scan internal LVM devices.
   Split-mirror operations were ignoring user-specified PVs.
   Fix data corruption bug in cluster mirrors.
   Require logical volume(s) to be explicitly named for lvconvert --merge.


