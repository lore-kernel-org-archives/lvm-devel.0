From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Jul 2010 13:35:57 -0000
Subject: LVM2 WHATS_NEW_DM
Message-ID: <20100708133557.22432.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-07-08 13:35:56

Modified files:
	.              : WHATS_NEW_DM 

Log message:
	Update for dmsetup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.392&r2=1.393

--- LVM2/WHATS_NEW_DM	2010/07/07 11:22:46	1.392
+++ LVM2/WHATS_NEW_DM	2010/07/08 13:35:55	1.393
@@ -1,5 +1,6 @@
 Version 1.02.53 -
 ===============================
+  Fix return value to 0 for 'dmsetup -c -o help'.
   Use "nowatch" udev rule for inappropriate devices.
 
 Version 1.02.52 - 6th July 2010


