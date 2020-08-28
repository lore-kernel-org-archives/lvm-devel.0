From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:15 +0000 (GMT)
Subject: master - gcc: calc size in compile time
Message-ID: <20200828195915.58B4E383E82A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7880896f0dbe730e7b47aa8040544434813eacc4
Commit:        7880896f0dbe730e7b47aa8040544434813eacc4
Parent:        fd8d926fc52badc93f7985b5db2f4cb6a75e81e4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 18:58:55 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:02 2020 +0200

gcc: calc size in compile time

---
 lib/device/dev-md.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 23ce41af1..8fe7fc361 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -50,7 +50,7 @@ static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
 }
 
 #define IMSM_SIGNATURE "Intel Raid ISM Cfg Sig. "
-#define IMSM_SIG_LEN (strlen(IMSM_SIGNATURE))
+#define IMSM_SIG_LEN (sizeof(IMSM_SIGNATURE) - 1)
 
 static int _dev_has_imsm_magic(struct device *dev, uint64_t devsize_sectors)
 {


