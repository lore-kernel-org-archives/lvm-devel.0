From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 26 Apr 2012 17:30:51 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/cluster.c da ...
Message-ID: <20120426173051.10211.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-26 17:30:50

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: cluster.c local.c 

Log message:
	Fix bug in cmirror that caused incorrect status info to print on some nodes.
	
	Looking at the code in cmirrord/local.c, we can see the various different
	request types handled in different ways.  Some information that is non-changing
	does not need to go around the cluster and can be short-circuited.  For
	example, once the cluster mirror is in-sync, it is pointless to continue
	sending that query around the cluster.  We can save network bandwidth and reply
	directly back to the kernel.  When it comes to status information, there are
	two types 'TABLE' and 'INFO'.  The 'TABLE' information never changes and
	belongs to the group of requests that can be safely short-circuited.  The
	'STATUS' information can change - and will change if a device fails.  Thus it
	cannot be short-circuited, but this is exactly what was found.  The 'STATUS'
	information request was being short-circuited and therefore never reporting the
	failure condition to anyone other than the "server" that experienced it
	directly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2394&r2=1.2395
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/local.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2012/04/26 15:24:46	1.2394
+++ LVM2/WHATS_NEW	2012/04/26 17:30:49	1.2395
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix bug in cmirror that caused incorrect status info to print on some nodes.
   Remove statement that snapshots cannot be tagged from lvm man page.
   Disallow changing cluster attribute of VG while RAID LVs are active.
   Fix lvconvert error message for non-mergeable volumes.
--- LVM2/daemons/cmirrord/cluster.c	2012/03/10 09:32:47	1.20
+++ LVM2/daemons/cmirrord/cluster.c	2012/04/26 17:30:50	1.21
@@ -1231,11 +1231,11 @@
 				   _RQ_TYPE(rq->u_rq.request_type),
 				   rq->originator, (response) ? "YES" : "NO");
 		else
-			LOG_SPRINT(match, "SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s, RSPR=%u",
+			LOG_SPRINT(match, "SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s, RSPR=%u, error=%d",
 				   rq->u_rq.seq, SHORT_UUID(rq->u_rq.uuid),
 				   _RQ_TYPE(rq->u_rq.request_type),
 				   rq->originator, (response) ? "YES" : "NO",
-				   nodeid);
+				   nodeid, rq->u_rq.error);
 	}
 }
 
--- LVM2/daemons/cmirrord/local.c	2012/03/10 09:32:47	1.10
+++ LVM2/daemons/cmirrord/local.c	2012/04/26 17:30:50	1.11
@@ -237,7 +237,6 @@
 	case DM_ULOG_GET_REGION_SIZE:
 	case DM_ULOG_IN_SYNC:
 	case DM_ULOG_GET_SYNC_COUNT:
-	case DM_ULOG_STATUS_INFO:
 	case DM_ULOG_STATUS_TABLE:
 	case DM_ULOG_PRESUSPEND:
 		/* We do not specify ourselves as server here */
@@ -273,6 +272,7 @@
 	case DM_ULOG_MARK_REGION:
 	case DM_ULOG_GET_RESYNC_WORK:
 	case DM_ULOG_SET_REGION_SYNC:
+	case DM_ULOG_STATUS_INFO:
 	case DM_ULOG_IS_REMOTE_RECOVERING:
 	case DM_ULOG_POSTSUSPEND:
 		r = cluster_send(rq);


