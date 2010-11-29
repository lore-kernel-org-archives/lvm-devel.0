From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 11:13:13 -0000
Subject: LVM2/lib/locking cluster_locking.c
Message-ID: <20101129111313.12761.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 11:13:12

Modified files:
	lib/locking    : cluster_locking.c 

Log message:
	Remove dead assignment in _lock_for_cluster
	
	'saved_errno' is not read from this initialization and before its
	usage is assigned again before _cluster_free_request() call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/lib/locking/cluster_locking.c	2010/08/17 19:25:05	1.46
+++ LVM2/lib/locking/cluster_locking.c	2010/11/29 11:13:12	1.47
@@ -308,7 +308,7 @@
 	const char *node = "";
 	int len;
 	int dmeventd_mode;
-	int saved_errno = errno;
+	int saved_errno;
 	lvm_response_t *response = NULL;
 	int num_responses;
 


