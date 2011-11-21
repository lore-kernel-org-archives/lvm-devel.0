From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 21 Nov 2011 12:44:42 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20111121124442.23251.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-11-21 12:44:39

Modified files:
	.              : WHATS_NEW 

Log message:
	More of WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2194&r2=1.2195

--- LVM2/WHATS_NEW	2011/11/21 12:33:56	1.2194
+++ LVM2/WHATS_NEW	2011/11/21 12:44:38	1.2195
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Replace the unit testing framework with CUnit (--enable-testing).
   Fix dmeventd snapshot monitoring when multiple extensions were involved.
   Don't ignore configure --mandir and --infodir.
   Drop pool memory allocated within lv_has_target_type().


