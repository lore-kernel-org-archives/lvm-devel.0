From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:27 +0000 (GMT)
Subject: stable-2.02 - gcc: calc size in compile time
Message-ID: <20201018210227.038AD385041B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=84f03e2b630c5266ed553fd7699955b4c52cbf7f
Commit:        84f03e2b630c5266ed553fd7699955b4c52cbf7f
Parent:        0c8f160fb2a020b4dba719e5d340f550b58d8f8c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 18:58:55 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:27:51 2020 +0200

gcc: calc size in compile time

---
 lib/device/dev-md.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 70154d69b..e345e926c 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -50,7 +50,7 @@ static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
 }
 
 #define IMSM_SIGNATURE "Intel Raid ISM Cfg Sig. "
-#define IMSM_SIG_LEN (strlen(IMSM_SIGNATURE))
+#define IMSM_SIG_LEN (sizeof(IMSM_SIGNATURE) - 1)
 
 static int _dev_has_imsm_magic(struct device *dev, uint64_t devsize_sectors)
 {


