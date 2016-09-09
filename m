From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Sep 2016 13:04:12 +0000 (UTC)
Subject: master - lvm2app: fix cache percantage reporting
Message-ID: <20160909130412.AB20A60DE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9350aa72184e08da0faa5f1fda2f245e6342a426
Commit:        9350aa72184e08da0faa5f1fda2f245e6342a426
Parent:        4b22cd81e6b3b60f08976df4104b7411d1af4fc5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 14:25:53 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 9 15:03:28 2016 +0200

lvm2app: fix cache percantage reporting

In lvm2app we were always returning dirty (copy%) value.
Return properly data & metadata usage values.
---
 WHATS_NEW               |    1 +
 lib/report/properties.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9584872..2c47452 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Fix lvm2api reporting of cache data and metadata percent.
   Restore reporting of metadata usage for cache volumes (2.02.155).
   Support raid scrubbing on cache origin LV.
 
diff --git a/lib/report/properties.c b/lib/report/properties.c
index d3feb07..3b27bdc 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -114,7 +114,7 @@ static dm_percent_t _data_percent(const struct logical_volume *lv)
 			stack;
 			return DM_PERCENT_INVALID;
 		}
-		percent = status->dirty_usage;
+		percent = status->data_usage;
 		dm_pool_destroy(status->mem);
 		return percent;
 	}
@@ -135,7 +135,7 @@ static dm_percent_t _metadata_percent(const struct logical_volume *lv)
 			stack;
 			return DM_PERCENT_INVALID;
 		}
-		percent = status->dirty_usage;
+		percent = status->metadata_usage;
 		dm_pool_destroy(status->mem);
 		return percent;
 	}


