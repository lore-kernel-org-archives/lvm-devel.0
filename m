From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 10 Aug 2015 19:30:31 +0000 (UTC)
Subject: master - libdm: simplify stats nr_areas calculation (Coverity)
Message-ID: <20150810193031.BD05160D8B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=856f9cced83078a90ca2291eff0758d42775f195
Commit:        856f9cced83078a90ca2291eff0758d42775f195
Parent:        ec87e88c5264511576341286b474b453a15594ba
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 10 19:18:16 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 10 20:26:07 2015 +0100

libdm: simplify stats nr_areas calculation (Coverity)

Remove an unneccessary conditional operator and simplify the logic
in _nr_areas:

libdm/libdm-stats.c: 501 in _nr_areas() - Control flow issues  (DEADCODE)
---
 libdm/libdm-stats.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index a672e05..192326e 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -503,8 +503,7 @@ static uint64_t _nr_areas(uint64_t len, uint64_t step)
 	 * treat the entire region as a single area. Any partial area at the
 	 * end of the region is treated as an additional complete area.
 	 */
-	return (len && step)
-		? (len / (step ? step : len)) + !!(len % step) : 0;
+	return (len / (step ? : len)) + !!(len % step);
 }
 
 static uint64_t _nr_areas_region(struct dm_stats_region *region)


