From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 29 Apr 2008 08:55:20 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-openais.c
Message-ID: <20080429085520.25895.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-04-29 08:55:20

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-openais.c 

Log message:
	. remove_lock_wait.diff remove the definition of "struct lock_wait",
	which is not used since the switch away from async version saLck
	. num_nodes should equal to member_list_entries, i.e.
	joined_list_entires is 0 when a node leaves the group.
	
	Thanks to Xinwei Hu for the patch.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.862&r2=1.863
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2008/04/28 08:57:11	1.862
+++ LVM2/WHATS_NEW	2008/04/29 08:55:19	1.863
@@ -1,5 +1,6 @@
 Version 2.02.36 - 
 =================================
+  Remove unused struct in clvmd-openais, and use correct node count.
   Fix nodes list in clvmd-openais, and allow for broadcast messages.
   Exclude VG_GLOBAL from internal concurrent VG lock counter.
   Fix vgsplit internal counting of snapshot LVs.
--- LVM2/daemons/clvmd/clvmd-openais.c	2008/04/28 08:57:11	1.5
+++ LVM2/daemons/clvmd/clvmd-openais.c	2008/04/29 08:55:20	1.6
@@ -100,13 +100,6 @@
 	SaNameT              lock_name;
 };
 
-struct lock_wait
-{
-	pthread_cond_t cond;
-	pthread_mutex_t mutex;
-	int status;
-};
-
 /* Set errno to something approximating the right value and return 0 or -1 */
 static int ais_to_errno(SaAisErrorT err)
 {
@@ -313,7 +306,7 @@
 		ninfo->state = NODE_CLVMD;
 	}
 
-	num_nodes = joined_list_entries;
+	num_nodes = member_list_entries;
 }
 
 static int lck_dispatch(struct local_client *client, char *buf, int len,


