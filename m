From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 10:25:59 +0000 (UTC)
Subject: master - libdm: fix region overlap tests
Message-ID: <20161213102559.DEEAD6066E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=138e4336fd8422623df7daa362b98a4899f5fbec
Commit:        138e4336fd8422623df7daa362b98a4899f5fbec
Parent:        93f420caf4e58f468919f40a9f3f9c20157affd0
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Dec 12 22:49:31 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 09:09:29 2016 +0000

libdm: fix region overlap tests

---
 libdm/libdm-stats.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 56a38f2..8c0428e 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -3880,6 +3880,12 @@ static int _stats_group_check_overlap(const struct dm_stats *dms,
 		i++;
 	}
 
+	/* A single region cannot overlap itself. */
+	if (i == 1) {
+		dm_pool_free(dms->mem, map);
+		return 1;
+	}
+
 	/* sort by extent.start */
 	qsort(map, count, sizeof(*map), _extent_start_compare);
 
@@ -3915,7 +3921,7 @@ merge:
 		goto merge;
 
 	dm_pool_free(dms->mem, map);
-	return overlap;
+	return (overlap == 0);
 }
 
 static void _stats_copy_histogram_bounds(struct dm_histogram *to,


