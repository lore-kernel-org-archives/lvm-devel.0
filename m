From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:48 +0000 (UTC)
Subject: master - report: always display 0 for pv_free field if we don't have any mda and PV is marked as used at the same time
Message-ID: <20160215120848.DDBAD60A9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db494d7d344f323c7255d6ceb9cd5180e4b6f23b
Commit:        db494d7d344f323c7255d6ceb9cd5180e4b6f23b
Parent:        d84a80afb5e65420fdca3c283754a90e5b0bacaa
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 11 15:00:43 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

report: always display 0 for pv_free field if we don't have any mda and PV is marked as used at the same time

---
 lib/report/report.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 3f2bd0c..c964bd8 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2363,6 +2363,7 @@ static int _pvused_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
+
 	uint64_t used = pv_used(pv);
 
 	return _size64_disp(rh, mem, field, &used, private);
@@ -2374,8 +2375,21 @@ static int _pvfree_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
+	struct lvmcache_info *info;
+	uint32_t ext_flags;
 	uint64_t freespace = pv_free(pv);
 
+	if (is_orphan(pv)) {
+		if (!(info = lvmcache_info_from_pvid((const char *) &pv->id, 0))) {
+			log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
+			return 0;
+		}
+
+		ext_flags = lvmcache_ext_flags(info);
+		if (ext_flags & PV_EXT_USED)
+			freespace = 0;
+	}
+
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 


