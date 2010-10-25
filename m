From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 12:57:01 -0000
Subject: LVM2/tools lvm.c
Message-ID: <20101025125701.4254.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 12:57:00

Modified files:
	tools          : lvm.c 

Log message:
	Fix potential NULL pointer dereference
	
	Makes clang happier as it covers all code paths and avoids NULL pointer
	dereference through the 'com' pointer (which is NULL by default static
	initialisation).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/tools/lvm.c	2010/07/09 15:34:48	1.113
+++ LVM2/tools/lvm.c	2010/10/25 12:57:00	1.114
@@ -85,11 +85,11 @@
 				break;
 			}
 		}
-
-		if (!com)
-			return NULL;
 	}
 
+	if (!com)
+		return NULL;
+
 	/* Short form arguments */
 	if (len < 3) {
 		while (match_no < com->num_args) {


