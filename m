From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 10 Dec 2019 09:46:46 -0500
Subject: master - clenaup: simpler form
Message-ID: <49912.119121009463600807@us-mta-15.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89d839e54116d29e78909c63eb20ab50dc00e93f
Commit:        89d839e54116d29e78909c63eb20ab50dc00e93f
Parent:        abc0a8faba2a1437f4f9d158310acb8af6ab2fe5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 28 15:15:10 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 15:44:16 2019 +0100

clenaup: simpler form

---
 lib/metadata/metadata.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 24958d0..246682c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4932,13 +4932,12 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			log_debug_metadata("Drop dev for MD component from cache %s.", dev_name(dev));
 			lvmcache_del_dev(dev);
 
-			dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
-				if (mda_get_device(mda) != dev)
-					continue;
-				log_debug_metadata("Drop mda from MD component from mda list %s.", dev_name(dev));
-				dm_list_del(&mda->list);
-				break;
-			}
+			dm_list_iterate_items(mda, &fid->metadata_areas_in_use)
+				if (mda_get_device(mda) == dev) {
+					log_debug_metadata("Drop mda from MD component from mda list %s.", dev_name(dev));
+					dm_list_del(&mda->list);
+					break;
+				}
 		}
 	}
 



