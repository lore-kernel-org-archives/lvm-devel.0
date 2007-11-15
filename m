From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 15 Nov 2007 10:16:14 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20071115101614.29615.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-11-15 10:16:14

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	If the pre_command fails then go back and wait patiently for the next
	pre function rather than retrying it until we get stuck!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.736&r2=1.737
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/WHATS_NEW	2007/11/15 02:20:03	1.736
+++ LVM2/WHATS_NEW	2007/11/15 10:16:14	1.737
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Stop clvmd going haywire if a pre_function fails.
   Convert some vg_reads into vg_lock_and_reads.
   Avoid nested vg_reads when processing PVs in VGs and fix associated locking.
   Accept sizes with --readahead argument.
--- LVM2/daemons/clvmd/clvmd.c	2007/08/17 11:51:23	1.39
+++ LVM2/daemons/clvmd/clvmd.c	2007/11/15 10:16:14	1.40
@@ -1379,8 +1379,10 @@
 			break;
 		} while(1);
 
-		if (status)
-			continue; /* Wait for another PRE command */
+		if (status) {
+			client->bits.localsock.state = POST_COMMAND;
+			goto next_pre;
+		}
 
 		/* We may need to wait for the condition variable before running the post command */
 		pthread_mutex_lock(&client->bits.localsock.mutex);
@@ -1409,7 +1411,7 @@
 			log_error("Error sending to pipe: %m\n");
 			break;
 		} while(1);
-
+next_pre:
 		DEBUGLOG("Waiting for next pre command\n");
 
 		pthread_mutex_lock(&client->bits.localsock.mutex);


