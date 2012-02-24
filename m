From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 24 Feb 2012 00:12:00 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120224001200.885.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-24 00:11:59

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Clean up the lvmetad state more thoroughly upon shutdown.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/23 23:52:11	1.40
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/24 00:11:59	1.41
@@ -941,6 +941,12 @@
 		n = dm_hash_get_next(ls->vgid_to_metadata, n);
 	}
 
+	n = dm_hash_get_first(ls->pvid_to_pvmeta);
+	while (n) {
+		dm_config_destroy(dm_hash_get_data(ls->pvid_to_pvmeta, n));
+		n = dm_hash_get_next(ls->pvid_to_pvmeta, n);
+	}
+
 	n = dm_hash_get_first(ls->lock.vg);
 	while (n) {
 		pthread_mutex_destroy(dm_hash_get_data(ls->lock.vg, n));
@@ -952,6 +958,8 @@
 	dm_hash_destroy(ls->pvid_to_pvmeta);
 	dm_hash_destroy(ls->device_to_pvid);
 	dm_hash_destroy(ls->vgid_to_metadata);
+	dm_hash_destroy(ls->vgid_to_vgname);
+	dm_hash_destroy(ls->vgname_to_vgid);
 	dm_hash_destroy(ls->pvid_to_vgid);
 	return 1;
 }


