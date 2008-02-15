From: meyering@sourceware.org <meyering@sourceware.org>
Date: 15 Feb 2008 14:12:34 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20080215141234.32380.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-02-15 14:12:33

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Remove redundant if-before-free tests in clvmd.c.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.794&r2=1.795
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW	2008/02/13 20:01:48	1.794
+++ LVM2/WHATS_NEW	2008/02/15 14:12:32	1.795
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Remove redundant if-before-free tests in clvmd.c.
   Avoid a compiler warning: make is_orphan's parameter "const".
   Fix lvconvert detection of mirror conversion in progress. (2.02.30)
   Avoid automatic lvconvert polldaemon invocation when -R specified. (2.02.30)
--- LVM2/daemons/clvmd/clvmd.c	2008/02/05 09:38:04	1.41
+++ LVM2/daemons/clvmd/clvmd.c	2008/02/15 14:12:32	1.42
@@ -903,8 +903,7 @@
 		}
 
 		/* Free the command buffer */
-		if (thisfd->bits.localsock.cmd)
-			free(thisfd->bits.localsock.cmd);
+		free(thisfd->bits.localsock.cmd);
 
 		/* Clear out the cross-link */
 		if (thisfd->bits.localsock.pipe_client != NULL)
@@ -939,8 +938,7 @@
 		}
 
 		/* Free any old buffer space */
-		if (thisfd->bits.localsock.cmd)
-			free(thisfd->bits.localsock.cmd);
+		free(thisfd->bits.localsock.cmd);
 
 		/* See if we have the whole message */
 		argslen =
@@ -1547,8 +1545,7 @@
 		}
 		thisreply = thisreply->next;
 
-		if (tempreply->replymsg)
-			free(tempreply->replymsg);
+		free(tempreply->replymsg);
 		free(tempreply);
 	}
 
@@ -1579,8 +1576,7 @@
 
 		thisreply = thisreply->next;
 
-		if (tempreply->replymsg)
-			free(tempreply->replymsg);
+		free(tempreply->replymsg);
 		free(tempreply);
 	}
 	client->bits.localsock.replies = NULL;
@@ -1732,8 +1728,7 @@
 			pthread_mutex_unlock(&lvm_thread_mutex);
 
 			process_work_item(cmd);
-			if (cmd->msg)
-				free(cmd->msg);
+			free(cmd->msg);
 			free(cmd);
 
 			pthread_mutex_lock(&lvm_thread_mutex);


