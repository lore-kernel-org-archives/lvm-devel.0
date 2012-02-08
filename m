From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 13:44:50 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20120208134450.30449.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 13:44:50

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	Move label_init up in code stack
	
	label_exit() is called destroy_toolcontext() and we are now
	using standard dm_list function for destroy, we have to make sure
	dm_list gets initialized properly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150

--- LVM2/lib/commands/toolcontext.c	2012/02/08 10:46:24	1.149
+++ LVM2/lib/commands/toolcontext.c	2012/02/08 13:44:49	1.150
@@ -896,8 +896,6 @@
 	const struct dm_config_node *cn;
 #endif
 
-	label_init();
-
 #ifdef LVM1_INTERNAL
 	if (!(fmt = init_lvm1_format(cmd)))
 		return 0;
@@ -1268,6 +1266,7 @@
 	dm_list_init(&cmd->segtypes);
 	dm_list_init(&cmd->tags);
 	dm_list_init(&cmd->config_files);
+	label_init();
 
 	/* FIXME Make this configurable? */
 	reset_lvm_errno(1);


