From: Milan Broz <mbroz@redhat.com>
Date: Thu, 12 Aug 2010 16:07:58 +0200
Subject: [PATCH 3/4] Fix file open leak in swap signature detection
In-Reply-To: <cover.1281621747.git.mbroz@redhat.com>
References: <cover.1281621747.git.mbroz@redhat.com>
Message-ID: <1c20ca9189be0fedcdaf8bf67cf268998b61eab5.1281621747.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/device/dev-swap.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index 62c2bb5..b8ebcca 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -42,7 +42,7 @@ int dev_is_swap(struct device *dev, uint64_t *signature)
 {
 	char buf[10];
 	uint64_t size;
-	int page;
+	int page, ret = 0;
 
 	if (!dev_get_size(dev, &size)) {
 		stack;
@@ -66,11 +66,12 @@ int dev_is_swap(struct device *dev, uint64_t *signature)
 			break;
 		if (!dev_read(dev, page - SIGNATURE_SIZE,
 			      SIGNATURE_SIZE, buf)) {
-			stack;
-			return -1;
+			ret = -1;
+			break;
 		}
 		if (_swap_detect_signature(buf)) {
 			*signature = page - SIGNATURE_SIZE;
+			ret = 1;
 			break;
 		}
 	}
@@ -78,10 +79,7 @@ int dev_is_swap(struct device *dev, uint64_t *signature)
 	if (!dev_close(dev))
 		stack;
 
-	if (*signature)
-		return 1;
-
-	return 0;
+	return ret;
 }
 
 #endif
-- 
1.7.1


