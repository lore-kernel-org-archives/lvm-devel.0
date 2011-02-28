From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2011 19:50:16 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20110228195016.4445.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-28 19:50:15

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Remove dead code
	
	Remove code which is no longer used.
	Code which has been using msg_malloced was removed in 2007.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/daemons/clvmd/clvmd.c	2011/02/18 14:47:29	1.95
+++ LVM2/daemons/clvmd/clvmd.c	2011/02/28 19:50:15	1.96
@@ -1392,7 +1392,6 @@
 	int replylen = 0;
 	int buflen = max_cluster_message - sizeof(struct clvm_header) - 1;
 	int status;
-	int msg_malloced = 0;
 
 	/* Get the node name as we /may/ need it later */
 	clops->name_from_csid(csid, nodename);
@@ -1501,10 +1500,6 @@
 		}
 	}
 
-	/* Free buffer if it was malloced */
-	if (msg_malloced) {
-		free(msg);
-	}
 	free(replyargs);
 }
 


