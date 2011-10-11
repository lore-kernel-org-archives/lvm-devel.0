From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 10:06:58 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20111011100658.19107.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 10:06:57

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Remove unused variables

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/daemons/clvmd/clvmd.c	2011/10/11 09:56:44	1.115
+++ LVM2/daemons/clvmd/clvmd.c	2011/10/11 10:06:57	1.116
@@ -1989,7 +1989,6 @@
  */
 static void *lvm_thread_fn(void *arg)
 {
-	struct dm_list *cmdl, *tmp;
 	sigset_t ss;
 	struct lvm_startup_params *lvm_params = arg;
 	struct lvm_thread_cmd *cmd;


