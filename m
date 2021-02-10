From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Feb 2021 14:43:52 +0000 (GMT)
Subject: main - dev-cache: remove duplicated allocation
Message-ID: <20210210144352.6E1BC3857C7B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=96910de4c7acbc11dc9f4c43925765847a059871
Commit:        96910de4c7acbc11dc9f4c43925765847a059871
Parent:        f74f94c2ddb1d33d75d325c959344a566a621fd5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 10 14:33:17 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 10 15:38:18 2021 +0100

dev-cache: remove duplicated allocation

Merge mistake missed to remove allocation that is now postponed
until it's really needed.
---
 lib/device/dev-cache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 2783d4acc..67e1386d3 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -329,7 +329,7 @@ enum add_hash {
 
 static int _add_alias(struct device *dev, const char *path, enum add_hash hash)
 {
-	struct dm_str_list *sl = _zalloc(sizeof(*sl));
+	struct dm_str_list *sl;
 	struct dm_str_list *strl;
 	const char *oldpath;
 	int prefer_old = 1;


