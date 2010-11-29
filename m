From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 11:05:15 -0000
Subject: LVM2/daemons/clvmd lvm-functions.c
Message-ID: <20101129110515.8572.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 11:05:15

Modified files:
	daemons/clvmd  : lvm-functions.c 

Log message:
	Remove printing of LCK_CACHE
	
	LCK_CACHE is defined as 0x100 so it cannot be passed through
	unsigned char parameter - remove it from the sprintf code.
	
	If the LCK_CLUSTER should be printed here - lot of code need
	to be reworked - so adding FIXME comment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/daemons/clvmd/lvm-functions.c	2010/11/23 01:55:58	1.100
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/11/29 11:05:15	1.101
@@ -44,6 +44,10 @@
 	int lock_mode;
 };
 
+/*
+ * FIXME: 8bit value passed here -
+ *        so only LCK_XXX defines < 0x100 can be decoded
+ */
 static const char *decode_locking_cmd(unsigned char cmdl)
 {
 	static char buf[128];
@@ -109,12 +113,11 @@
 		break;
 	}
 
-	sprintf(buf, "0x%x %s (%s|%s%s%s%s%s%s)", cmdl, command, type, scope,
+	sprintf(buf, "0x%x %s (%s|%s%s%s%s%s)", cmdl, command, type, scope,
 		cmdl & LCK_NONBLOCK   ? "|NONBLOCK" : "",
 		cmdl & LCK_HOLD       ? "|HOLD" : "",
 		cmdl & LCK_LOCAL      ? "|LOCAL" : "",
-		cmdl & LCK_CLUSTER_VG ? "|CLUSTER_VG" : "",
-		cmdl & LCK_CACHE      ? "|CACHE" : "");
+		cmdl & LCK_CLUSTER_VG ? "|CLUSTER_VG" : "");
 
 	return buf;
 }


