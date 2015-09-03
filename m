From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:08:31 +0000 (UTC)
Subject: master - dmstats: support --noheadings for histogram fields
Message-ID: <20150903210831.C5DE4603F2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49b5022993cd57f7fda416bd62d182cdbe209fb8
Commit:        49b5022993cd57f7fda416bd62d182cdbe209fb8
Parent:        84d88cb2cf11ecb3c186477cd3c79cef0fa1c378
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Sep 3 21:56:34 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Sep 3 22:04:11 2015 +0100

dmstats: support --noheadings for histogram fields

---
 tools/dmsetup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index ea30a3c..432677b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3443,7 +3443,7 @@ static const char *_get_histogram_string(const struct dm_stats *dms, int rel,
 					 int vals, int bounds)
 {
 	const struct dm_histogram *dmh;
-	int flags = 0;
+	int flags = 0, width = (_switches[NOHEADINGS_ARG]) ? -1 : 0;
 
 	if (!(dmh = dm_stats_get_histogram(dms, DM_STATS_REGION_CURRENT,
 					   DM_STATS_AREA_CURRENT)))
@@ -3460,7 +3460,7 @@ static const char *_get_histogram_string(const struct dm_stats *dms, int rel,
 	flags |= (_switches[NOTIMESUFFIX_ARG]) ? 0 : DM_HISTOGRAM_SUFFIX;
 
 	/* FIXME: make unit conversion optional. */
-	return dm_histogram_to_string(dmh, -1, 0, flags);
+	return dm_histogram_to_string(dmh, -1, width, flags);
 }
 
 static int _stats_hist_count_disp(struct dm_report *rh,


