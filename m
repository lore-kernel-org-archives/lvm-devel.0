From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Wed, 16 Dec 2020 09:55:59 -0000
Subject: [PATCH] dev_name(): add to judge whether the dev->aliases list is empty
Message-ID: <4f9d1853-8980-511e-3431-c0d549b18a5f@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If dev->aliases linked list is empty, then directly obtain the str address
of dm_str_list saved in dev->aliases.n, an unknown address will be returned,
which may cause segfault

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 lib/device/dev-cache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d5f18ff..9441924 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1629,8 +1629,8 @@ int dev_fd(struct device *dev)

 const char *dev_name(const struct device *dev)
 {
-	return (dev && dev->aliases.n) ? dm_list_item(dev->aliases.n, struct dm_str_list)->str :
-	    unknown_device_name();
+	return (dev && dev->aliases.n && !dm_list_empty(&dev->aliases)) ? \
+		dm_list_item(dev->aliases.n, struct dm_str_list)->str : unknown_device_name();
 }

 bool dev_cache_has_md_with_end_superblock(struct dev_types *dt)
-- 
1.8.3.1


