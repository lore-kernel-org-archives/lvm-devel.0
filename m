From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:17:57 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101220131757.11815.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:17:57

Modified files:
	.              : WHATS_NEW 

Log message:
	update

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1840&r2=1.1841

--- LVM2/WHATS_NEW	2010/12/20 13:12:58	1.1840
+++ LVM2/WHATS_NEW	2010/12/20 13:17:56	1.1841
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Check read() and close() results in _get_cmdline().
   Add const for struct config_node usage.
   Fix NULL pointer check in error path in clvmd do_command(). (2.02.78)
   Fix device.c #include to ensure 64-bit fopen64 use. (2.02.51)


