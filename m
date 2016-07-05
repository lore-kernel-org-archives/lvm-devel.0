From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:55:26 +0000 (UTC)
Subject: master - libdm: fix <backtrace> in dm_stats_get_nr_regions
Message-ID: <20160705185526.38E6C613E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53e92441a613270750c12089b119337a71ff545a
Commit:        53e92441a613270750c12089b119337a71ff545a
Parent:        cf0fa3d69319755be0d6fb0c7f692f89e49f5881
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 18:33:02 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:17 2016 +0100

libdm: fix <backtrace> in dm_stats_get_nr_regions

---
 libdm/libdm-stats.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 93b8e0b..ab15589 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2132,8 +2132,12 @@ void dm_stats_buffer_destroy(struct dm_stats *dms, char *buffer)
 
 uint64_t dm_stats_get_nr_regions(const struct dm_stats *dms)
 {
-	if (!dms || !dms->regions)
+	if (!dms)
 		return_0;
+
+	if (!dms->regions)
+		return 0;
+
 	return dms->nr_regions;
 }
 


