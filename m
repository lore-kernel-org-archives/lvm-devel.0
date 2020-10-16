From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:59 +0000 (GMT)
Subject: stable-2.02 - gcc: keep using unsigned type
Message-ID: <20201016191059.9EADE396EC6A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=29436d6da9f219002e0fe650fde66ab8f86c7b43
Commit:        29436d6da9f219002e0fe650fde66ab8f86c7b43
Parent:        d53456be24942d6bef018f73b6d098c15c7c023c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 22:24:34 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:06 2020 +0200

gcc: keep using unsigned type

---
 libdm/libdevmapper.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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


