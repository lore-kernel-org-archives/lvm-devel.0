From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:57 +0100
Subject: [PATCH 10/12] Remove constant expression check
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <460a19466acfb19791797e1d2378edadb93d7296.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

"result_independent_of_operands: ((dev->dev & 0xfff00UL) >> 8) ==
18446744073709551615UL /* -1 */ is always false regardless of the values
of its operands (logical operand of if)."

'dev->dev' is set in dev-cache.c _insert() and it's not expectable
st_rdev would have '-1'

Thought even if it would - it'd be still missed it by macro
transformation.

My proposal is to remove this check competely.

For linux it's noop anyway.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/filters/filter.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index c66939a..4c3d3b7 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -64,9 +64,6 @@ int dev_subsystem_part_major(const struct device *dev)
 {
 	dev_t primary_dev;
 
-	if (MAJOR(dev->dev) == -1)
-		return 0;
-
 	if (MAJOR(dev->dev) == _md_major)
 		return 1;
 
-- 
1.7.7.3


