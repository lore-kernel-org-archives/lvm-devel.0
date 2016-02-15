From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:30:46 +0000 (UTC)
Subject: master - cleanup: use is_used_pv fn to detect whether PV is in use while reporting pv_free field
Message-ID: <20160215123046.71D5A60353@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=abbaeef096251c4191e6da2518e646dd78b82da8
Commit:        abbaeef096251c4191e6da2518e646dd78b82da8
Parent:        698e0eb851b280796e3fbe17fbe9a9158b6344c7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 15 13:30:37 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 13:30:37 2016 +0100

cleanup: use is_used_pv fn to detect whether PV is in use while reporting pv_free field

---
 lib/report/report.c |   18 +++++-------------
 1 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index c964bd8..123b9f0 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2375,20 +2375,12 @@ static int _pvfree_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
-	struct lvmcache_info *info;
-	uint32_t ext_flags;
-	uint64_t freespace = pv_free(pv);
+	uint64_t freespace;
 
-	if (is_orphan(pv)) {
-		if (!(info = lvmcache_info_from_pvid((const char *) &pv->id, 0))) {
-			log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
-			return 0;
-		}
-
-		ext_flags = lvmcache_ext_flags(info);
-		if (ext_flags & PV_EXT_USED)
-			freespace = 0;
-	}
+	if (is_orphan(pv) && is_used_pv(pv))
+		freespace = 0;
+	else
+		freespace = pv_free(pv);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }


