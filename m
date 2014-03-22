From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Mar 2014 19:43:51 +0000 (UTC)
Subject: master - dev-swap: use SECTOR_SHIFT
Message-ID: <20140322194351.55E99606B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c595b20e56f21505e8380c9b00801639143ee945
Commit:        c595b20e56f21505e8380c9b00801639143ee945
Parent:        936bfeb8de3cbaa756a75bfe453a99efe8aa3006
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 22 20:43:05 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 22 20:43:05 2014 +0100

dev-swap: use SECTOR_SHIFT

---
 lib/device/dev-swap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index bf3604b..d1feb0c 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -59,7 +59,7 @@ int dev_is_swap(struct device *dev, uint64_t *offset_found)
 		 */
 		if (page == 0x8000)
 			continue;
-		if (size < (page / 512))
+		if (size < (page >> SECTOR_SHIFT))
 			break;
 		if (!dev_read(dev, page - SIGNATURE_SIZE,
 			      SIGNATURE_SIZE, buf)) {


