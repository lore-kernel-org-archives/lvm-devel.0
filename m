From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed, 14 Dec 2016 11:29:42 +0000 (UTC)
Subject: master - libdm: use destination size as limit in dm_bit_copy()
Message-ID: <20161214112943.034F460D1E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=35791689ba5ef95da45290fd12ce9cff55c86258
Commit:        35791689ba5ef95da45290fd12ce9cff55c86258
Parent:        0f98d5c2e6d103a46bb5eca75ac496622933c475
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Dec 12 20:28:29 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Dec 14 11:28:11 2016 +0000

libdm: use destination size as limit in dm_bit_copy()

The dm_bit_copy() macro uses the source (bs1) bitset size as the
limit for memcpy:

    memcpy((bs1) + 1, (bs2) + 1, ((*(bs1) / DM_BITS_PER_INT) + 1)..)

This is safe if the destination bitset is smaller than the source,
or if the two bitsets are of the same size.

With a destination that is larger (e.g. when resizing a bitmap to
add more capacity), the memcpy will overrun the source bitset and
set garbage bits in the destination.

There are nine uses of the macro currently (8 in libdm/regex, and
1 in daemons/cmirrord): in each case the two bitsets are always of
equal size so the behaviour is unchanged.

Fix the macro to use bs2's size to simplify resizing bitsets and
avoid the need for another copy macro.
---
 libdm/libdevmapper.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index bcf784b..ed46795 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2090,7 +2090,7 @@ int dm_bit_get_prev(dm_bitset_t bs, int last_bit);
    memset((bs) + 1, 0, ((*(bs) / DM_BITS_PER_INT) + 1) * sizeof(int))
 
 #define dm_bit_copy(bs1, bs2) \
-   memcpy((bs1) + 1, (bs2) + 1, ((*(bs1) / DM_BITS_PER_INT) + 1) * sizeof(int))
+   memcpy((bs1) + 1, (bs2) + 1, ((*(bs2) / DM_BITS_PER_INT) + 1) * sizeof(int))
 
 /*
  * Parse a string representation of a bitset into a dm_bitset_t. The


