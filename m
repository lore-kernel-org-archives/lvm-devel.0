From: Dave Wysochanski <wysochanski@pobox.com>
Date: Mon, 22 Nov 2010 22:25:13 -0500
Subject: [PATCH] Fix seg_size lvm2app property - should return bytes.
Message-ID: <1290482713-18054-1-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

All 'size' values of lvm2app properties should be in bytes.
Fix 'seg_size' to return bytes.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 lib/report/properties.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index b93f419..edbaecd 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -230,7 +230,7 @@ GET_LVSEG_NUM_PROPERTY_FN(seg_start, lvseg_start(lvseg))
 #define _seg_start_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start_pe, lvseg->le)
 #define _seg_start_pe_set _not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(seg_size, lvseg_size(lvseg))
+GET_LVSEG_NUM_PROPERTY_FN(seg_size, (SECTOR_SIZE * lvseg_size(lvseg)))
 #define _seg_size_set _not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_tags, lvseg_tags_dup(lvseg))
 #define _seg_tags_set _not_implemented_set
-- 
1.7.2.2


