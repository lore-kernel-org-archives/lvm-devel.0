From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 24 Jan 2017 10:04:23 +0000 (UTC)
Subject: master - libdm: fix stats comment formatting in libdevmapper.h
Message-ID: <20170124100423.ECA1561006@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca427a711a33b02264689dcfca4bc5e5d2f9434e
Commit:        ca427a711a33b02264689dcfca4bc5e5d2f9434e
Parent:        ec93f37b86977380b59080981fb912ff30dd80ab
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jan 24 09:29:08 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jan 24 09:29:31 2017 +0000

libdm: fix stats comment formatting in libdevmapper.h

---
 libdm/libdevmapper.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 363cf8e..3c96bd9 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1320,8 +1320,9 @@ int dm_stats_get_group_descriptor(const struct dm_stats *dms,
  * On success the function returns a pointer to an array of uint64_t
  * containing the IDs of the newly created regions. The region_id
  * array is terminated by the value DM_STATS_REGION_NOT_PRESENT and
- * should be freed using dm_free() when no longer required. On error
- * NULL is returned.
+ * should be freed using dm_free() when no longer required.
+ *
+ * On error NULL is returned.
  *
  * Following a call to dm_stats_create_regions_from_fd() the handle
  * is guaranteed to be in a listed state, and to contain any region
@@ -1329,7 +1330,6 @@ int dm_stats_get_group_descriptor(const struct dm_stats *dms,
  *
  * The group_id for the new group is equal to the region_id value in
  * the first array element.
- *
  */
 uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 					  int group, int precise,


