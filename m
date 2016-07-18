From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 18 Jul 2016 17:50:01 +0000 (UTC)
Subject: master - libdm: document use of dm_free() with histogram bounds
Message-ID: <20160718175001.ECE0C60158@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=252952ff339bd928cc4e5ed34958d2845365b397
Commit:        252952ff339bd928cc4e5ed34958d2845365b397
Parent:        da146ae9b90b90607324672207d1be37f16b0e7a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Jul 18 18:20:01 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Jul 18 18:48:34 2016 +0100

libdm: document use of dm_free() with histogram bounds

---
 libdm/libdevmapper.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 0f61f9c..2270016 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -805,6 +805,10 @@ int dm_stats_get_region_nr_histogram_bins(const struct dm_stats *dms,
  * magnitude is one milisecond: attempting to use a histogram with a
  * boundary less than one milisecond when creating a region will cause
  * the region to be created with the precise_timestamps feature enabled.
+ *
+ * On sucess a pointer to the struct dm_histogram representing the
+ * bounds values is returned, or NULL in the case of error. The returned
+ * pointer should be freed using dm_free() when no longer required.
  */
 struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str);
 


