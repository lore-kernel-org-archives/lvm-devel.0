From: Bryn Reeves <bmr@sourceware.org>
Date: Fri, 10 Mar 2017 11:44:52 -0500
Subject: master - libdm: make dm_stats_destroy(NULL) a no-op
Message-ID: <201703101644.v2AGiqpi012211@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d28a50ec76c62c48a3be695569fe5e752b9ae684
Commit:        d28a50ec76c62c48a3be695569fe5e752b9ae684
Parent:        93644be44b4067c6ebc1d450589ca510129b3b60
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Mar 10 16:41:28 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Mar 10 16:41:28 2017 +0000

libdm: make dm_stats_destroy(NULL) a no-op

Test for NULL in dm_stats_destroy() and return immediately if
the struct dm_stats pointer is NULL (similar to free(NULL)).

This simplifies cleanup code which otherwise needs to:

  out:
    if (dms)
        dm_stats_destroy(dms);
    return;
---
 libdm/libdm-stats.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 61c052f..c83c27b 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2387,6 +2387,9 @@ bad:
  */
 void dm_stats_destroy(struct dm_stats *dms)
 {
+	if (!dms)
+		return;
+
 	_stats_regions_destroy(dms);
 	_stats_groups_destroy(dms);
 	_stats_clear_binding(dms);


