From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 May 2023 14:22:28 +0000 (GMT)
Subject: main - cov: validate dev_get_primary_dev result
Message-ID: <20230510142228.70D3D3853831@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b52a663a6436581cfacd9212929db551a00920f
Commit:        7b52a663a6436581cfacd9212929db551a00920f
Parent:        0cc5c2203b72e84b12cc93f2f73fb679f3f7ae09
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 10 13:28:38 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 10 15:27:48 2023 +0200

cov: validate dev_get_primary_dev result

Make sure primary_dev is defined when using it.
---
 lib/device/dev-mpath.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/device/dev-mpath.c b/lib/device/dev-mpath.c
index 5433b64e1..e6fc63afd 100644
--- a/lib/device/dev-mpath.c
+++ b/lib/device/dev-mpath.c
@@ -688,7 +688,8 @@ int dev_is_mpath_component(struct cmd_context *cmd, struct device *dev, dev_t *h
 	 * primary_result 2: dev is a partition, primary_dev is the whole device
 	 * primary_result 1: dev is a whole device
 	 */
-	primary_result = dev_get_primary_dev(dt, dev, &primary_dev);
+	if (!(primary_result = dev_get_primary_dev(dt, dev, &primary_dev)))
+		return_0;
 
 	if (_dev_is_mpath_component_sysfs(cmd, dev, primary_result, primary_dev, holder_devno) == 1)
 		goto found;

