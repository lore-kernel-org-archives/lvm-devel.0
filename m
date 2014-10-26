From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 26 Oct 2014 18:48:28 +0000 (UTC)
Subject: master - pools: workaround hints
Message-ID: <20141026184829.004D1608F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e223c801fc3eb12c2a4502aee471f18a0b903de8
Commit:        e223c801fc3eb12c2a4502aee471f18a0b903de8
Parent:        c28a7706ed00c135e6fb06d22dde1c374f32f847
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 26 19:45:17 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 26 19:45:17 2014 +0100

pools: workaround hints

Missing code for stacked hint estimation
---
 lib/metadata/pool_manip.c          |   29 +++++++++++++++++++----------
 test/shell/lvconvert-cache-raid.sh |    1 +
 2 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index b84950c..d1b4497 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -324,16 +324,25 @@ int recalculate_pool_chunk_size_with_dev_hints(struct logical_volume *pool_lv,
 
 	pool_data_lv = seg_lv(first_seg(pool_lv), 0);
 	dm_list_iterate_items(seg, &pool_data_lv->segments) {
-		pv = seg_pv(seg, 0);
-		if (chunk_size_calc_policy == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE)
-			hint = dev_optimal_io_size(cmd->dev_types, pv_dev(pv));
-		else
-			hint = dev_minimum_io_size(cmd->dev_types, pv_dev(pv));
-		if (!hint)
-			continue;
-		if (previous_hint)
-			hint = _lcm(previous_hint, hint);
-		previous_hint = hint;
+		switch (seg_type(seg, 0)) {
+		case AREA_PV:
+			pv = seg_pv(seg, 0);
+			if (chunk_size_calc_policy == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE)
+				hint = dev_optimal_io_size(cmd->dev_types, pv_dev(pv));
+			else
+				hint = dev_minimum_io_size(cmd->dev_types, pv_dev(pv));
+			if (!hint)
+				continue;
+
+			if (previous_hint)
+				hint = _lcm(previous_hint, hint);
+			previous_hint = hint;
+			break;
+		case AREA_LV:
+			/* FIXME: hint for stacked (raid) LVs - estimate geometry from LV ?? */
+		default:
+			break;
+		}
 	}
 
 	if (!hint)
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 3ac2d0b..16dd38e 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -46,6 +46,7 @@ lvremove -f $vg
 
 lvcreate -n cpool_meta -m 1 --type raid1 -l 10 $vg
 lvcreate -n cpool -m 1 --type raid1 -l 10 $vg
+lvs -a -o+seg_pe_ranges $vg
 lvconvert --yes --type cache-pool --poolmetadata $vg/cpool_meta $vg/cpool
 lvcreate -n corigin --type cache --cachepool $vg/cpool -l 10
 


