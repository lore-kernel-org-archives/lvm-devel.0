From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:16:47 -0400
Subject: master - libdm: do not attempt filemap cleanup if dm_stats_list() fails (coverity)
Message-ID: <201703292016.v2TKGliA000866@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6740eb1c2b8cde6aabce0d9b0847c01b69210065
Commit:        6740eb1c2b8cde6aabce0d9b0847c01b69210065
Parent:        f86c1f5d0a38afc9d174e59af4bab83127e4b2b8
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 17:41:03 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 18:34:43 2017 +0100

libdm: do not attempt filemap cleanup if dm_stats_list() fails (coverity)

---
 libdm/libdm-stats.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 94696fb..3e2983d 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4743,7 +4743,8 @@ out_remove:
 	 * single list operation and call _stats_delete_region() directly
 	 * to avoid a @stats_list ioctl and list parsing for each region.
 	 */
-	dm_stats_list(dms, NULL);
+	if (!dm_stats_list(dms, NULL))
+		goto out;
 
 	fail_region = i;
 	_stats_cleanup_region_ids(dms, regions, fail_region);


