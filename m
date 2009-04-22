From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Apr 2009 12:46:26 -0000
Subject: LVM2 daemons/clogd/cluster.c tools/lvchange.c
Message-ID: <20090422124626.16465.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-04-22 12:46:25

Modified files:
	daemons/clogd  : cluster.c 
	tools          : lvchange.c 

Log message:
	Remove some trailing whitespace so git won't complain.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/daemons/clogd/cluster.c	2009/04/21 19:16:22	1.2
+++ LVM2/daemons/clogd/cluster.c	2009/04/22 12:46:25	1.3
@@ -1087,7 +1087,7 @@
 
 		new->next = match->checkpoint_list;
 		match->checkpoint_list = new;
-	}		
+	}
 
 out:
 	/* nothing happens after this point.  It is just for debugging */
@@ -1281,7 +1281,7 @@
 			j--;
 		}
 	}
-	match->checkpoints_needed = j;			
+	match->checkpoints_needed = j;
 
 	if (left->nodeid < my_cluster_id) {
 		match->delay = (match->delay > 0) ? match->delay - 1 : 0;
--- LVM2/tools/lvchange.c	2009/04/21 14:31:58	1.97
+++ LVM2/tools/lvchange.c	2009/04/22 12:46:25	1.98
@@ -74,7 +74,7 @@
 		goto out;
 	}
 
-	r = 1;	
+	r = 1;
 out:
 	backup(lv->vg);
 	return r;


