From: James M Leddy <james.leddy@redhat.com>
Date: Wed, 9 Mar 2011 20:56:24 -0500
Subject: endless loop in _free_vginfo
Message-ID: <20110310015624.GA8900@xander.lga.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Concerning the _free_vginfo function field in cache/lvmcache.c.  It
looks like this code is supposed to traverse a list (list of vgs with
the same name?), but the assignment is the same on every
iteration. cache/lvmcache.c: 809

	if (vginfo == primary_vginfo) {
		dm_hash_remove(_vgname_hash, vginfo->vgname);
		if (vginfo->next && !dm_hash_insert(_vgname_hash, vginfo->vgname,
						    vginfo->next)) {
			log_error("_vgname_hash re-insertion for %s failed",
				  vginfo->vgname);
			r = 0;
		}
	} else do
		if (vginfo2->next == vginfo) {
			vginfo2->next = vginfo->next;
			break;
		}
 	while ((vginfo2 = primary_vginfo->next));


Shouldn't it be this ?

diff -c /home/james/rpmbuild/lvm2/2.02.72-8.fc14.4/work/LVM2.2.02.72/lib/cache/lvmcache.c /tmp/buffer-content-2482n5q
--- /home/james/rpmbuild/lvm2/2.02.72-8.fc14.4/work/LVM2.2.02.72/lib/cache/lvmcache.c	2010-07-09 11:34:42.000000000 -0400
+++ /tmp/buffer-content-2482n5q	2011-03-09 20:42:39.946008936 -0500
@@ -819,7 +819,7 @@
 			vginfo2->next = vginfo->next;
 			break;
 		}
- 	while ((vginfo2 = primary_vginfo->next));
+ 	while ((vginfo2 = vginfo2->next));
 
 	if (vginfo->vgname)
 		dm_free(vginfo->vgname);



We ran into this when we have duplicate PV, probably also have a
duplicate VG if that is what exposes this bug.


-- 
James M. Leddy
Technical Account Manager
Red Hat Inc.


