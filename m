From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Sep 2011 12:38:44 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20110902123844.4257.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-02 12:38:44

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	Add missing 'static' for local function
	
	Avoid missing prototype warning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135

--- LVM2/lib/commands/toolcontext.c	2011/09/02 01:59:07	1.134
+++ LVM2/lib/commands/toolcontext.c	2011/09/02 12:38:43	1.135
@@ -558,7 +558,7 @@
 	return 1;
 }
 
-struct dm_config_tree *_merge_config_files(struct cmd_context *cmd, struct dm_config_tree *cft)
+static struct dm_config_tree *_merge_config_files(struct cmd_context *cmd, struct dm_config_tree *cft)
 {
 	struct config_tree_list *cfl;
 


