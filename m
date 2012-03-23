From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Mar 2012 10:34:52 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120323103452.20521.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-23 10:34:51

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Add fixmes
	
	There is missing some proper reaction when update fails ?

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/03/23 10:33:27	1.48
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/03/23 10:34:51	1.49
@@ -675,6 +675,7 @@
 	assert(oldname);
 
 	if (update_pvids)
+		/* FIXME: What should happen when update fails */
 		update_pvid_to_vgid(s, old, "#orphan", 0);
 	/* need to update what we have since we found a newer version */
 	dm_hash_remove(s->vgid_to_metadata, vgid);
@@ -804,7 +805,8 @@
 	unlock_vgid_to_metadata(s);
 
 	if (retval)
-		update_pvid_to_vgid(s, cft, vgid, 1);
+		/* FIXME: What should happen when update fails */
+		retval = update_pvid_to_vgid(s, cft, vgid, 1);
 
 	unlock_pvid_to_vgid(s);
 out:


