From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:57 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lvm1: Do not call into lvmcache from low-level code.
Message-ID: <20130605120557.56E4160F90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1650e1467ca35e3a4dfece81bcda2e2c23bf046b
Commit:        1650e1467ca35e3a4dfece81bcda2e2c23bf046b
Parent:        94d9562bea6d0fa5bc7e919cb34090ffe6b45fd9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Feb 18 16:20:20 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:36 2013 +0200

lvm1: Do not call into lvmcache from low-level code.

This path is not performance-sensitive anyway (LVM1 is long deprecated) and
disk-rep is very low-level code that has no business talking to lvmcache.
---
 lib/format1/disk-rep.c |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index 19776e0..adc38ba 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -493,24 +493,6 @@ int read_pvs_in_vg(const struct format_type *fmt, const char *vg_name,
 	baton.mem = mem;
 	baton.vg_name = vg_name;
 
-	/* Fast path if we already saw this VG and cached the list of PVs */
-	if (vg_name && (vginfo = lvmcache_vginfo_from_vgname(vg_name, NULL))) {
-
-		lvmcache_foreach_pv(vginfo, _read_pv_in_vg, &baton);
-
-		if (!baton.empty) {
-			/* Did we find the whole VG? */
-			if (!vg_name || is_orphan_vg(vg_name) ||
-			    (baton.data && *baton.data->pvd.vg_name &&
-			     dm_list_size(head) == baton.data->vgd.pv_cur))
-				return 1;
-
-			/* Failed */
-			dm_list_init(head);
-			/* vgcache_del(vg_name); */
-		}
-	}
-
 	if (!(iter = dev_iter_create(filter, 1))) {
 		log_error("read_pvs_in_vg: dev_iter_create failed");
 		return 0;


