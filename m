From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Aug 2010 13:12:32 -0000
Subject: LVM2 WHATS_NEW_DM
Message-ID: <20100811131232.21930.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-08-11 13:12:31

Modified files:
	.              : WHATS_NEW_DM 

Log message:
	WHATS_NEW_DM

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.404&r2=1.405

--- LVM2/WHATS_NEW_DM	2010/08/03 13:39:27	1.404
+++ LVM2/WHATS_NEW_DM	2010/08/11 13:12:31	1.405
@@ -1,5 +1,6 @@
 Version 1.02.54 - 
 ================================
+  Fix segfault in regex matcher with characters of ordinal value > 127.
   Use built-in rule for device aliases: block/ < dm- < disk/ < mapper/ < other.
   Wait for node creation before displaying debug info in dmsetup.
   Fix return status 0 for "dmsetup info -c -o help".


