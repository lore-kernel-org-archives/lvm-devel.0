From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Jul 2011 19:11:25 -0000
Subject: LVM2/lib/config config.c config.h
Message-ID: <20110719191125.10660.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-19 19:11:24

Modified files:
	lib/config     : config.c config.h 

Log message:
	Add an API to config.h for creating values in the config_tree mempool.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/lib/config/config.c	2011/07/18 13:26:08	1.98
+++ LVM2/lib/config/config.c	2011/07/19 19:11:24	1.99
@@ -1419,6 +1419,12 @@
 	return cn;
 }
 
+struct config_value *create_config_value(struct config_tree *cft)
+{
+	struct cs *c = (struct cs *) cft;
+	return _create_value(c->mem);
+}
+
 struct dm_pool *config_tree_memory(struct config_tree *cft)
 {
 	struct cs *c = (struct cs *) cft;
--- LVM2/lib/config/config.h	2011/07/18 13:26:08	1.34
+++ LVM2/lib/config/config.h	2011/07/19 19:11:24	1.35
@@ -124,6 +124,7 @@
 					       const struct config_node *node,
 					       int siblings);
 struct config_node *create_config_node(struct config_tree *cft, const char *key);
+struct config_value *create_config_value(struct config_tree *cft);
 struct config_node *clone_config_node(struct config_tree *cft, const struct config_node *cn,
 				      int siblings);
 


