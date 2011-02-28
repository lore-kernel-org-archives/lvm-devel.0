From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2011 19:53:04 -0000
Subject: LVM2/lib activate/dev_manager.c config/config. ...
Message-ID: <20110228195304.7481.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-28 19:53:03

Modified files:
	lib/activate   : dev_manager.c 
	lib/config     : config.c 
	lib/metadata   : lv_manip.c 

Log message:
	Add fall through comments
	
	Add comments to switch case construct.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.213&r2=1.214
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.250&r2=1.251

--- LVM2/lib/activate/dev_manager.c	2011/02/04 20:30:18	1.213
+++ LVM2/lib/activate/dev_manager.c	2011/02/28 19:53:03	1.214
@@ -1687,6 +1687,7 @@
 		dm_tree_skip_lockfs(root);
 		if (!dm->flush_required && (lv->status & MIRRORED) && !(lv->status & PVMOVE))
 			dm_tree_use_no_flush_suspend(root);
+		/* Fall through */
 	case SUSPEND_WITH_LOCKFS:
 		if (!dm_tree_suspend_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
 			goto_out;
--- LVM2/lib/config/config.c	2011/02/18 14:08:22	1.89
+++ LVM2/lib/config/config.c	2011/02/28 19:53:03	1.90
@@ -808,6 +808,7 @@
 
 	case '.':
 		p->t = TOK_FLOAT;
+		/* Fall through */
 	case '0':
 	case '1':
 	case '2':
--- LVM2/lib/metadata/lv_manip.c	2011/02/27 01:16:53	1.250
+++ LVM2/lib/metadata/lv_manip.c	2011/02/28 19:53:03	1.251
@@ -1512,6 +1512,7 @@
 
 				case PREFERRED:
 					preferred_count++;
+					/* Fall through */
 
 				case NEXT_PV:
 					goto next_pv;


