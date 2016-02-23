From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:19 +0000 (UTC)
Subject: master - coverity: check for info pointer existance
Message-ID: <20160223204119.E05936104D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b08eb91df132e84fa41b4cf06707629b2c5c895e
Commit:        b08eb91df132e84fa41b4cf06707629b2c5c895e
Parent:        2e168a52b07bb9dc659bdcda80fc77031edebbd6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 19:48:01 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:40:16 2016 +0100

coverity: check for info pointer existance

Since we already check in few other places  'info' is not NULL,
do the same for others - however when info would be NULL
it more or less looks like internal error.
---
 lib/cache/lvmetad.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index b68e6c9..a483e04 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1062,14 +1062,16 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 		return_0;
 	}
 
+	/* TODO: resolve what does it actually mean  'info == NULL'
+	 *       missing info is likely an INTERNAL_ERROR */
 	if (!config_make_nodes(pvmeta, pvmeta->root, NULL,
 			       "device = %"PRId64, (int64_t) dev->dev,
 			       "dev_size = %"PRId64, (int64_t) (info ? lvmcache_device_size(info) : 0),
 			       "format = %s", fmt->name,
 			       "label_sector = %"PRId64, (int64_t) label_sector,
 			       "id = %s", uuid,
-			       "ext_version = %"PRId64, (int64_t) lvmcache_ext_version(info),
-			       "ext_flags = %"PRId64, (int64_t) lvmcache_ext_flags(info),
+			       "ext_version = %"PRId64, (int64_t) (info ? lvmcache_ext_version(info) : 0),
+			       "ext_flags = %"PRId64, (int64_t) (info ? lvmcache_ext_flags(info) : 0),
 			       NULL))
 	{
 		dm_config_destroy(pvmeta);


