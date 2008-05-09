From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 9 May 2008 09:59:39 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20080509095939.24865.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-05-09 09:59:39

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Fix uninitialised mutex in clvmd if all daemons are not running at startup.
	
	Thanks to Mark Hlawatschek for pointing this out.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.871&r2=1.872
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/WHATS_NEW	2008/05/09 07:20:04	1.871
+++ LVM2/WHATS_NEW	2008/05/09 09:59:39	1.872
@@ -1,5 +1,6 @@
 Version 2.02.38 - 
 =================================
+  Fix uninitialised mutex in clvmd if all daemons are not running at startup.
   Make clvmd-cman use a hash rather than an array for node updown info.
   Check lv_count in vg_validate.
   Add --prefixes to reporting tools for field name prefix output format.
--- LVM2/daemons/clvmd/clvmd.c	2008/03/28 12:58:09	1.45
+++ LVM2/daemons/clvmd/clvmd.c	2008/05/09 09:59:39	1.46
@@ -530,7 +530,7 @@
 		char nodename[max_cluster_member_name_len];
 
 		clops->name_from_csid(csid, nodename);
-		DEBUGLOG("PJC: checking for a reply from %s\n", nodename);
+		DEBUGLOG("Checking for a reply from %s\n", nodename);
 		pthread_mutex_lock(&client->bits.localsock.reply_mutex);
 
 		reply = client->bits.localsock.replies;
@@ -541,7 +541,7 @@
 		pthread_mutex_unlock(&client->bits.localsock.reply_mutex);
 
 		if (!reply) {
-			DEBUGLOG("PJC: node %s timed-out\n", nodename);
+			DEBUGLOG("Node %s timed-out\n", nodename);
 			add_reply_to_list(client, ETIMEDOUT, csid,
 					  "Command timed out", 18);
 		}
@@ -985,6 +985,14 @@
 			}
 		}
 
+		/* Initialise and lock the mutex so the subthread will wait after
+		   finishing the PRE routine */
+		if (!thisfd->bits.localsock.threadid) {
+			pthread_mutex_init(&thisfd->bits.localsock.mutex, NULL);
+			pthread_cond_init(&thisfd->bits.localsock.cond, NULL);
+			pthread_mutex_init(&thisfd->bits.localsock.reply_mutex, NULL);
+		}
+
 		/* Only run the command if all the cluster nodes are running CLVMD */
 		if (((inheader->flags & CLVMD_FLAG_LOCAL) == 0) &&
 		    (check_all_clvmds_running(thisfd) == -1)) {
@@ -1056,12 +1064,6 @@
 
 		thisfd->bits.localsock.pipe = comms_pipe[1];
 
-		/* Initialise and lock the mutex so the subthread will wait after
-		   finishing the PRE routine */
-		pthread_mutex_init(&thisfd->bits.localsock.mutex, NULL);
-		pthread_cond_init(&thisfd->bits.localsock.cond, NULL);
-		pthread_mutex_init(&thisfd->bits.localsock.reply_mutex, NULL);
-
 		/* Make sure the thread has a copy of it's own ID */
 		newfd->bits.pipe.threadid = thisfd->bits.localsock.threadid;
 


