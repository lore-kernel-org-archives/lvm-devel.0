From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Dec 2011 22:31:11 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20111218223111.24005.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-18 22:31:11

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Fix up lvmetad for the minor API change in dm_config_create.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/10/30 21:58:59	1.27
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/12/18 22:31:10	1.28
@@ -175,7 +175,7 @@
 
 	metadata = cft->root;
 
-	res.cft = dm_config_create(NULL, 0);
+	res.cft = dm_config_create();
 
 	/* The response field */
 	res.cft->root = n = dm_config_create_node(res.cft, "response");
@@ -295,7 +295,7 @@
 		goto out;
 	}
 
-	cft = dm_config_create(NULL, 0);
+	cft = dm_config_create();
 	cft->root = dm_config_clone_node(cft, metadata, 0);
 	vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
 


