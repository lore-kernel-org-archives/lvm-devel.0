From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 15 Jan 2010 16:18:15 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM
Message-ID: <20100115161815.23562.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-15 16:18:14

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 

Log message:
	udpate WHATS_NEW*

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1388&r2=1.1389
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.337&r2=1.338

--- LVM2/WHATS_NEW	2010/01/14 14:42:06	1.1388
+++ LVM2/WHATS_NEW	2010/01/15 16:18:14	1.1389
@@ -1,5 +1,6 @@
 Version 2.02.59 - 
 ===================================
+  Fix difference between CTR table built and expected for cluster log.
 
 Version 2.02.58 - 14th January 2010
 ===================================
--- LVM2/WHATS_NEW_DM	2010/01/14 14:42:06	1.337
+++ LVM2/WHATS_NEW_DM	2010/01/15 16:18:14	1.338
@@ -1,5 +1,6 @@
 Version 1.02.43 - 
 ===================================
+  Fix off-by-one error causing bad cluster mirror table construction.
 
 Version 1.02.42 - 14th January 2010
 ===================================


