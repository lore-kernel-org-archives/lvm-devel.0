From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  6 Jul 2016 10:16:46 +0000 (UTC)
Subject: master - libdm: use log_err_once() for group histogram message
Message-ID: <20160706101646.EE85B61BEB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a497b95db15a24c82f29fd8b00de5fbd1e56b1c5
Commit:        a497b95db15a24c82f29fd8b00de5fbd1e56b1c5
Parent:        28658541daef567f0f767190c244a100ea45476f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jul 6 11:16:12 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jul 6 11:16:12 2016 +0100

libdm: use log_err_once() for group histogram message

---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 06aa645..12c821f 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -3179,7 +3179,7 @@ struct dm_histogram *dm_stats_get_histogram(const struct dm_stats *dms,
 
 	/* FIXME return histogram sum? Requires bounds check at group time */
 	if (region_id & DM_STATS_WALK_GROUP) {
-		log_warn("Group histogram data is not supported");
+		log_err_once("Group histogram data is not supported");
 		return NULL;
 	}
 


