From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Oct 2010 13:53:29 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101013135329.20515.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-13 13:53:26

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1757&r2=1.1758

--- LVM2/WHATS_NEW	2010/10/13 10:37:27	1.1757
+++ LVM2/WHATS_NEW	2010/10/13 13:53:25	1.1758
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Give correct error message when creating a too-small snapshot.
   Implement vgextend --restoremissing.
   Refactor and add 'get' functions for lv properties/fields.
   Update script for fsadm testing.


