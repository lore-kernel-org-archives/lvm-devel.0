From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:29:33 +0200
Subject: [PATCH 3/6] nextbit
In-Reply-To: <cover.1278505444.git.zkabelac@redhat.com>
References: <cover.1278505444.git.zkabelac@redhat.com>
Message-ID: <a631b5e87462434ba4ca7e6514adf174bdcf81b9.1278505444.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/datastruct/bitset.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/datastruct/bitset.c b/libdm/datastruct/bitset.c
index 9b8aff9..563f684 100644
--- a/libdm/datastruct/bitset.c
+++ b/libdm/datastruct/bitset.c
@@ -69,9 +69,9 @@ void dm_bit_union(dm_bitset_t out, dm_bitset_t in1, dm_bitset_t in2)
 
 static int _test_word(uint32_t test, int bit)
 {
-	int next_set_bit;
+	uint32_t tb = test >> bit;
 
-	return ((next_set_bit = ffs(test >> bit)) ? next_set_bit + bit - 1 : -1);
+	return (tb ? ffs(tb) + bit - 1 : -1);
 }
 
 int dm_bit_get_next(dm_bitset_t bs, int last_bit)
-- 
1.7.1.1


