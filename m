From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Apr 2010 13:52:21 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100414135221.27126.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-14 13:52:21

Modified files:
	.              : WHATS_NEW 

Log message:
	What's new.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1520&r2=1.1521

--- LVM2/WHATS_NEW	2010/04/14 13:09:16	1.1520
+++ LVM2/WHATS_NEW	2010/04/14 13:52:20	1.1521
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Allow incomplete mirror restore in lvconvert --repair upon insufficient space.
   Do not reset position in metadata ring buffer on vgrename and vgcfgrestore.
   Allow VGs with active LVs to be renamed.
   Use UUIDs instead of names while processing event handlers.


