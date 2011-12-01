From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Dec 2011 14:57:31 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20111201145731.24137.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-12-01 14:57:31

Modified files:
	tools          : dmsetup.c 

Log message:
	update old comment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.169&r2=1.170

--- LVM2/tools/dmsetup.c	2011/09/22 17:12:28	1.169
+++ LVM2/tools/dmsetup.c	2011/12/01 14:57:30	1.170
@@ -2049,6 +2049,11 @@
 		_out_char(']');
 }
 
+/* FIXME Display table or status line. (Disallow both?) */
+static void _display_tree_targets(struct dm_tree_node *node, unsigned depth)
+{
+}
+
 static void _display_tree_node(struct dm_tree_node *node, unsigned depth,
 			       unsigned first_child __attribute__((unused)),
 			       unsigned last_child, unsigned has_children)
@@ -2109,7 +2114,7 @@
 
 	if (TR_PRINT_TARGETS) {
 		_tree_more[depth + 1] = has_children;
-		// FIXME _display_tree_targets(name, depth + 2);
+		_display_tree_targets(node, depth + 2);
 	}
 }
 


