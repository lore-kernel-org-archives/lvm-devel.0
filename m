From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 18 Jul 2016 17:50:06 +0000 (UTC)
Subject: master - dmstats: fix bounds leak in _do_stats_create_regions() (Coverity)
Message-ID: <20160718175006.1CFE560158@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da49d4d54eac64a491b133bdb95e8dd04b6cde8f
Commit:        da49d4d54eac64a491b133bdb95e8dd04b6cde8f
Parent:        d2bf6742f845df13bae39ae157cfabf44252c570
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Jul 18 18:46:21 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Jul 18 18:48:34 2016 +0100

dmstats: fix bounds leak in _do_stats_create_regions() (Coverity)

---
 tools/dmsetup.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 985f63b..ff42a9e 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4842,15 +4842,15 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 	struct dm_info info;
 	void *next = NULL;
 
-	if (histogram && !(bounds = dm_histogram_bounds_from_string(histogram)))
-		return_0;
-
 	if (_switches[ALIAS_ARG] && _switches[NOGROUP_ARG]) {
 		log_error("Cannot set alias with --nogroup.");
 		dm_stats_destroy(dms);
 		return 0;
 	}
 
+	if (histogram && !(bounds = dm_histogram_bounds_from_string(histogram)))
+		return_0;
+
 	if (!(dmt = dm_task_create(DM_DEVICE_TABLE))) {
 		dm_histogram_bounds_destroy(bounds);
 		dm_stats_destroy(dms);


