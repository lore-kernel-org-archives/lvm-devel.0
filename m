From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:30 +0100
Subject: [PATCH 26/29] Add stack traces for dev_set/close_immediate error path
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <acfd28ed06270c5e3ccb1ffae903c48a9e2a3bc2.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 31f1ff3..6f553cd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3033,9 +3033,13 @@ int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	if (sectors > lv->size)
 		sectors = lv->size;
 
-	dev_set(dev, UINT64_C(0), (size_t) sectors << SECTOR_SHIFT, value);
+	if (!dev_set(dev, UINT64_C(0), (size_t) sectors << SECTOR_SHIFT, value))
+		stack;
+
 	dev_flush(dev);
-	dev_close_immediate(dev);
+
+	if (!dev_close_immediate(dev))
+                stack;
 
 	return 1;
 }
-- 
1.7.3.2


