From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 12 Jan 2012 09:08:55 -0000
Subject: LVM2/lib/activate activate.c
Message-ID: <20120112090855.21163.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-01-12 09:08:55

Modified files:
	lib/activate   : activate.c 

Log message:
	Missing const.
	
	"warning: assignment discards 'const' qualifier..."

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.227&r2=1.228

--- LVM2/lib/activate/activate.c	2012/01/12 01:51:56	1.227
+++ LVM2/lib/activate/activate.c	2012/01/12 09:08:55	1.228
@@ -395,7 +395,7 @@
 static int _passes_readonly_filter(struct cmd_context *cmd,
 				   struct logical_volume *lv)
 {
-	struct dm_config_node *cn;
+	const struct dm_config_node *cn;
 
 	if (!(cn = find_config_tree_node(cmd, "activation/read_only_volume_list")))
 		return 0;


