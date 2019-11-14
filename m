From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:21 -0500
Subject: master - cov: fix memleak for duplicate device
Message-ID: <36738.119111412071700751@us-mta-412.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44bf9c9a6af2d76d4de04b456362abd4ed454ff9
Commit:        44bf9c9a6af2d76d4de04b456362abd4ed454ff9
Parent:        82e6b820b84512ffb9f124c5d450c1036e7dd843
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:08:20 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

cov: fix memleak for duplicate device

For  dev_in_device_list() != 0 allocated  'devl' was
actually leaking - so instead allocate 'devl' only
when !dev_in_device_list() and indent code around.
---
 lib/cache/lvmcache.c |   29 +++++++++++++++--------------
 1 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 99818de..25d110d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1952,24 +1952,25 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 
 			strncpy(dev->pvid, pvid_s, sizeof(dev->pvid));
 
-			/*
-			 * Keep the existing PV/dev in lvmcache, and save the
-			 * new duplicate in the list of duplicates.  After
-			 * scanning is complete, compare the duplicate devs
-			 * with those in lvmcache to check if one of the
-			 * duplicates is preferred and if so switch lvmcache to
-			 * use it.
-			 */
-
-			if (!(devl = zalloc(sizeof(*devl))))
-				return_NULL;
-			devl->dev = dev;
-
 			/* shouldn't happen */
 			if (dev_in_device_list(dev, &_initial_duplicates))
 				log_debug_cache("Initial duplicate already in list %s", dev_name(dev));
-			else
+			else {
+				/*
+				 * Keep the existing PV/dev in lvmcache, and save the
+				 * new duplicate in the list of duplicates.  After
+				 * scanning is complete, compare the duplicate devs
+				 * with those in lvmcache to check if one of the
+				 * duplicates is preferred and if so switch lvmcache to
+				 * use it.
+				 */
+
+				if (!(devl = zalloc(sizeof(*devl))))
+					return_NULL;
+				devl->dev = dev;
+
 				dm_list_add(&_initial_duplicates, &devl->list);
+			}
 
 			if (is_duplicate)
 				*is_duplicate = 1;



