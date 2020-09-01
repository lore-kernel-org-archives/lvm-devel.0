From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:04 +0000 (GMT)
Subject: master - gcc: keep using unsigned type
Message-ID: <20200901170204.31AA23951892@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=de837c15a55f4951f0b3181f4835fed2d824698b
Commit:        de837c15a55f4951f0b3181f4835fed2d824698b
Parent:        534760398c54aaa67144ddd7303456da8758674a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 22:24:34 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

gcc: keep using unsigned type

---
 device_mapper/all.h  | 2 +-
 libdm/libdevmapper.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/device_mapper/all.h b/device_mapper/all.h
index ace3b69a0..df47d1a5a 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -1317,7 +1317,7 @@ int dm_bit_get_next(dm_bitset_t bs, int last_bit);
 int dm_bit_get_last(dm_bitset_t bs);
 int dm_bit_get_prev(dm_bitset_t bs, int last_bit);
 
-#define DM_BITS_PER_INT (sizeof(int) * CHAR_BIT)
+#define DM_BITS_PER_INT ((unsigned)sizeof(int) * CHAR_BIT)
 
 #define dm_bit(bs, i) \
    ((bs)[((i) / DM_BITS_PER_INT) + 1] & (0x1 << ((i) & (DM_BITS_PER_INT - 1))))
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 059b96f0b..a61ffe17e 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2242,7 +2242,7 @@ int dm_bit_get_next(dm_bitset_t bs, int last_bit);
 int dm_bit_get_last(dm_bitset_t bs);
 int dm_bit_get_prev(dm_bitset_t bs, int last_bit);
 
-#define DM_BITS_PER_INT (sizeof(int) * CHAR_BIT)
+#define DM_BITS_PER_INT ((unsigned)sizeof(int) * CHAR_BIT)
 
 #define dm_bit(bs, i) \
    ((bs)[((i) / DM_BITS_PER_INT) + 1] & (0x1 << ((i) & (DM_BITS_PER_INT - 1))))


