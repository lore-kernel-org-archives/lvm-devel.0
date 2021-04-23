From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:04 +0000 (GMT)
Subject: main - clang: remove unused assignment
Message-ID: <20210423210604.3F356393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a099707c433f0b3f2644c52f7773751832693a4
Commit:        6a099707c433f0b3f2644c52f7773751832693a4
Parent:        49caa9f3b1950ffd2ca9aa990e8bf0b480b62b87
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 23 17:27:44 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

clang: remove unused assignment

---
 lib/device/dev-md.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 78a77a968..6ddeb5b9e 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -55,7 +55,7 @@ static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
 static int _dev_has_imsm_magic(struct device *dev, uint64_t devsize_sectors)
 {
 	char imsm_signature[IMSM_SIG_LEN];
-	uint64_t off = (devsize_sectors * 512) - 1024;
+	uint64_t off;
 	unsigned int physical_block_size = 0;
 	unsigned int logical_block_size = 0;
 


