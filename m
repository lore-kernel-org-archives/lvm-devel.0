From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Dec 2013 13:09:07 +0000 (UTC)
Subject: master - lv_dependency: scan also snapshots and extorigins
Message-ID: <20131217130907.E77C16004F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94137b72edf232a0e82758c1669f1f60f2df3c50
Commit:        94137b72edf232a0e82758c1669f1f60f2df3c50
Parent:        760714829bfd6f3cc6e0f23f029baf4cc9ed441d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 17 13:53:15 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 17 14:08:54 2013 +0100

lv_dependency: scan also snapshots and extorigins

When LV is scanned for its dependencies - scan also origin's snapshots,
and thin external origins.

So if any PV from snapshot or external origin device is missing - lvm2 will
avoid trying to activate such device.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1679131..a7522f9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Dependency scan counts with snapshots and external origins.
   Make sure VG extent size is always greater or equal to PV phys. block size.
   Optimize double call of stat() for cached devices.
   Enable support for thin provisioning for default configuration.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 84d3200..4d4778b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2019,6 +2019,7 @@ static int _lv_each_dependency(struct logical_volume *lv,
 {
 	unsigned i, s;
 	struct lv_segment *lvseg;
+	struct dm_list *snh;
 
 	struct logical_volume *deps[] = {
 		(lv->rdevice && lv != lv->rdevice->lv) ? lv->rdevice->lv : 0,
@@ -2031,6 +2032,8 @@ static int _lv_each_dependency(struct logical_volume *lv,
 	}
 
 	dm_list_iterate_items(lvseg, &lv->segments) {
+		if (lvseg->external_lv && !fn(lvseg->external_lv, data))
+			return_0;
 		if (lvseg->log_lv && !fn(lvseg->log_lv, data))
 			return_0;
 		if (lvseg->rlog_lv && !fn(lvseg->rlog_lv, data))
@@ -2044,6 +2047,12 @@ static int _lv_each_dependency(struct logical_volume *lv,
 				return_0;
 		}
 	}
+
+	if (lv_is_origin(lv))
+		dm_list_iterate(snh, &lv->snapshot_segs)
+			if (!fn(dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, data))
+				return_0;
+
 	return 1;
 }
 


