From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Feb 2012 13:46:24 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20120210134624.21411.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-10 13:46:23

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Remove unreachable code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/daemons/dmeventd/dmeventd.c	2012/02/08 11:36:18	1.87
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/02/10 13:46:23	1.88
@@ -1907,7 +1907,6 @@
 		case 'V':
 			printf("dmeventd version: %s\n", DM_LIB_VERSION);
 			exit(1);
-			break;
 		}
 	}
 


