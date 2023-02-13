From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:36 +0000 (GMT)
Subject: main - cov: drop unneeded header
Message-ID: <20230213133136.195933858436@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2241982f9636592268fc75b17d1a00e0ee786a65
Commit:        2241982f9636592268fc75b17d1a00e0ee786a65
Parent:        02fdb2480e8ec1d7b3da14e620295d0f93bff52a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 13 09:34:20 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 13:41:59 2023 +0100

cov: drop unneeded header

---
 tools/vgchange.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 7d1bbd70a..09ade96a6 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -16,7 +16,6 @@
 #include "tools.h"
 #include "lib/device/device_id.h"
 #include "lib/label/hints.h"
-#include "lib/filters/filter.h"
 
 struct vgchange_params {
 	int lock_start_count;

