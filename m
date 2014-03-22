From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Mar 2014 19:39:30 +0000 (UTC)
Subject: master - dev-swap: detect swap signature on devices smaller then 2MB
Message-ID: <20140322193930.898E460F86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=936bfeb8de3cbaa756a75bfe453a99efe8aa3006
Commit:        936bfeb8de3cbaa756a75bfe453a99efe8aa3006
Parent:        93d77455eaa06c111954bc29c052fdaf4f31464e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 22 20:36:14 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 22 20:36:14 2014 +0100

dev-swap: detect swap signature on devices smaller then 2MB

Smallest supported size for swap device is 40KB, however current
test skipped devices smaller then 4096 sectors (2MB).

Since page is in bytes, convert it to sectors before comparing
with device size (in sectors).
---
 WHATS_NEW             |    1 +
 lib/device/dev-swap.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bdfe111..3fd6a8a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix swap signature detection for devices smaller then 2MB.
   Reindent some clvmd.c code.
   Use dm_malloc function in clvmd.c.
   Resolve memory release order for clvmd shutdown.
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index f506eda..bf3604b 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -59,7 +59,7 @@ int dev_is_swap(struct device *dev, uint64_t *offset_found)
 		 */
 		if (page == 0x8000)
 			continue;
-		if (size < page)
+		if (size < (page / 512))
 			break;
 		if (!dev_read(dev, page - SIGNATURE_SIZE,
 			      SIGNATURE_SIZE, buf)) {


