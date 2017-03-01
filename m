From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 1 Mar 2017 13:31:21 -0500
Subject: master - lvconvert: add new reporting fields for reshaping
Message-ID: <201703011831.v21IVLA4011334@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=daf1d4cadc69aeb8f4d83e44697948150ffcfda3
Commit:        daf1d4cadc69aeb8f4d83e44697948150ffcfda3
Parent:        fb42874a4f4b5e69a930be7b39c4ca9ad9e7e47f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Mar 1 19:30:52 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Mar 1 19:30:52 2017 +0100

lvconvert: add new reporting fields for reshaping

Commit 48778bc5038f introduced new RAID reshaping related report fields.

The inclusioon of segtype.h in properties.c isn't mandatory, remove it.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/report/properties.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 5264eb1..04f2cef 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -16,7 +16,6 @@
 #include "properties.h"
 #include "activate.h"
 #include "metadata.h"
-#include "segtype.h"
 
 
 #define GET_VG_NUM_PROPERTY_FN(NAME, VALUE) \
@@ -461,7 +460,7 @@ GET_LVSEG_NUM_PROPERTY_FN(parity_chunks, lvseg->data_offset)
 #define _parity_chunks_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(stripes, lvseg->area_count)
 #define _stripes_set prop_not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(data_stripes, lvseg->area_count - lvseg->segtype->parity_devs)
+GET_LVSEG_NUM_PROPERTY_FN(data_stripes, lvseg->area_count)
 #define _data_stripes_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(stripe_size, (SECTOR_SIZE * lvseg->stripe_size))
 #define _stripe_size_set prop_not_implemented_set


