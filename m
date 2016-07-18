From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 18 Jul 2016 17:49:57 +0000 (UTC)
Subject: master - libdm: free hist_arg in _stats_create_file_regions() (Coverity)
Message-ID: <20160718174957.B3B3F60158@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ef1f345498045b6757247dc64baad8252260583
Commit:        4ef1f345498045b6757247dc64baad8252260583
Parent:        4b4d4670042db3edb1270097f4d6046a6a827bac
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Jul 18 18:08:51 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Jul 18 18:09:21 2016 +0100

libdm: free hist_arg in _stats_create_file_regions() (Coverity)

---
 libdm/libdm-stats.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 57ef11d..1c2e19b 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4323,6 +4323,8 @@ static uint64_t *_stats_create_file_regions(struct dm_stats *dms, int fd,
 	}
 	regions[*count] = DM_STATS_REGION_NOT_PRESENT;
 
+	if (bounds)
+		dm_free(hist_arg);
 	dm_pool_free(dms->mem, extents);
 	return regions;
 
@@ -4335,6 +4337,7 @@ out_remove:
 
 out:
 	dm_pool_free(dms->mem, extents);
+	dm_free(hist_arg);
 	dm_free(regions);
 	return NULL;
 }


