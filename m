From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Nov 2011 10:59:05 +0100
Subject: [PATCH 3/7] Do not drop cache block_size for cached device.
In-Reply-To: <cover.1322213495.git.zkabelac@redhat.com>
References: <cover.1322213495.git.zkabelac@redhat.com>
Message-ID: <f2f4439fc5a68e40d1f97fa7e19a59d5d1eeb766.1322213495.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When we read i.e. read_ahead value - we open/close device,
which will cause dropping and rechecking device for the
block_size value.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/device/dev-io.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 46b90b5..bf30fe0 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -587,7 +587,6 @@ static void _close(struct device *dev)
 	if (close(dev->fd))
 		log_sys_error("close", dev_name(dev));
 	dev->fd = -1;
-	dev->block_size = -1;
 	dm_list_del(&dev->open_list);
 
 	log_debug("Closed %s", dev_name(dev));
-- 
1.7.7.3


