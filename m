From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 16 Jun 2015 19:24:43 +0000 (UTC)
Subject: master - xlate: add new variants
Message-ID: <20150616192443.9856960DAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7fe5e4010ce210b54cfcd7b81d088227fde9b23a
Commit:        7fe5e4010ce210b54cfcd7b81d088227fde9b23a
Parent:        ce18fb61c0a3b94b642edb056a717a198473449c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 16 09:30:14 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 16 09:30:14 2015 -0500

xlate: add new variants

New variants use the clearer function names from the kernel.
---
 lib/mm/xlate.h |   82 +++++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 63 insertions(+), 19 deletions(-)

diff --git a/lib/mm/xlate.h b/lib/mm/xlate.h
index 0d243c4..efb9ee3 100644
--- a/lib/mm/xlate.h
+++ b/lib/mm/xlate.h
@@ -38,27 +38,71 @@
 #endif
 
 #if BYTE_ORDER == LITTLE_ENDIAN
-#  define xlate16(x) (x)
-#  define xlate32(x) (x)
-#  define xlate64(x) (x)
-#  define xlate16_be(x) bswap_16(x)
-#  define xlate32_be(x) bswap_32(x)
-#  define xlate64_be(x) bswap_64(x)
+/* New clearer variants. */
+#define le16_to_cpu(x) (x)
+#define le32_to_cpu(x) (x)
+#define le64_to_cpu(x) (x)
+#define cpu_to_le16(x) (x)
+#define cpu_to_le32(x) (x)
+#define cpu_to_le64(x) (x)
+#define be16_to_cpu(x) bswap_16(x)
+#define be32_to_cpu(x) bswap_32(x)
+#define be64_to_cpu(x) bswap_64(x)
+#define cpu_to_be16(x) bswap_16(x)
+#define cpu_to_be32(x) bswap_32(x)
+#define cpu_to_be64(x) bswap_64(x)
+/* Old alternative variants. */
+#define xlate16(x) (x)
+#define xlate32(x) (x)
+#define xlate64(x) (x)
+#define xlate16_be(x) bswap_16(x)
+#define xlate32_be(x) bswap_32(x)
+#define xlate64_be(x) bswap_64(x)
+
 #elif BYTE_ORDER == BIG_ENDIAN
-#  define xlate16(x) bswap_16(x)
-#  define xlate32(x) bswap_32(x)
-#  define xlate64(x) bswap_64(x)
-#  define xlate16_be(x) (x)
-#  define xlate32_be(x) (x)
-#  define xlate64_be(x) (x)
+/* New clearer variants. */
+#define le16_to_cpu(x) bswap_16(x)
+#define le32_to_cpu(x) bswap_32(x)
+#define le64_to_cpu(x) bswap_64(x)
+#define cpu_to_le16(x) bswap_16(x)
+#define cpu_to_le32(x) bswap_32(x)
+#define cpu_to_le64(x) bswap_64(x)
+#define be16_to_cpu(x) (x)
+#define be32_to_cpu(x) (x)
+#define be64_to_cpu(x) (x)
+#define cpu_to_be16(x) (x)
+#define cpu_to_be32(x) (x)
+#define cpu_to_be64(x) (x)
+/* Old alternative variants. */
+#define xlate16(x) bswap_16(x)
+#define xlate32(x) bswap_32(x)
+#define xlate64(x) bswap_64(x)
+#define xlate16_be(x) (x)
+#define xlate32_be(x) (x)
+#define xlate64_be(x) (x)
+
 #else
-#  include <asm/byteorder.h>
-#  define xlate16(x) __cpu_to_le16((x))
-#  define xlate32(x) __cpu_to_le32((x))
-#  define xlate64(x) __cpu_to_le64((x))
-#  define xlate16_be(x) __cpu_to_be16((x))
-#  define xlate32_be(x) __cpu_to_be32((x))
-#  define xlate64_be(x) __cpu_to_be64((x))
+#include <asm/byteorder.h>
+/* New clearer variants. */
+#define le16_to_cpu(x) __le16_to_cpu(x)
+#define le32_to_cpu(x) __le32_to_cpu(x)
+#define le64_to_cpu(x) __le64_to_cpu(x)
+#define cpu_to_le16(x) __cpu_to_le16(x)
+#define cpu_to_le32(x) __cpu_to_le32(x)
+#define cpu_to_le64(x) __cpu_to_le64(x)
+#define be16_to_cpu(x) __be16_to_cpu(x)
+#define be32_to_cpu(x) __be32_to_cpu(x)
+#define be64_to_cpu(x) __be64_to_cpu(x)
+#define cpu_to_be16(x) __cpu_to_be16(x)
+#define cpu_to_be32(x) __cpu_to_be32(x)
+#define cpu_to_be64(x) __cpu_to_be64(x)
+/* Old alternative variants. */
+#define xlate16(x) __cpu_to_le16(x)
+#define xlate32(x) __cpu_to_le32(x)
+#define xlate64(x) __cpu_to_le64(x)
+#define xlate16_be(x) __cpu_to_be16(x)
+#define xlate32_be(x) __cpu_to_be32(x)
+#define xlate64_be(x) __cpu_to_be64(x)
 #endif
 
 #endif


