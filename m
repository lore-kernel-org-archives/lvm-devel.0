From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 17 Jun 2009 20:54:20 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20090617205420.2945.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-17 20:54:20

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	Properly destroy toolcontext.
	
	(fixes previous commit)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/lib/commands/toolcontext.c	2009/06/15 11:56:36	1.75
+++ LVM2/lib/commands/toolcontext.c	2009/06/17 20:54:20	1.76
@@ -517,10 +517,12 @@
 	struct config_tree_list *cfl;
 
 	dm_list_iterate_items(cfl, &cmd->config_files) {
+		if (cfl->cft == cmd->cft)
+			cmd->cft = NULL;
 		destroy_config_tree(cfl->cft);
 	}
 
-	if (cmd->cft && cmd->cft->root) {
+	if (cmd->cft) {
 		destroy_config_tree(cmd->cft);
 		cmd->cft = NULL;
 	}


