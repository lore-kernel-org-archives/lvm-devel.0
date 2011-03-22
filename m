From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:34:14 +0100
Subject: [PATCH 5/8] Simplify boundary checks
In-Reply-To: <cover.1300829383.git.zkabelac@redhat.com>
References: <cover.1300829383.git.zkabelac@redhat.com>
Message-ID: <64085d5c4de223063375070cadb01410b382eb96.1300829383.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As we do not support such large allocation they could wrap around
the pointer size - I think this optimisation is correct
and make the code easier to read and understand.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/mm/pool-fast.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index b651449..29d61a4 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -92,7 +92,7 @@ void *dm_pool_alloc_aligned(struct dm_pool *p, size_t s, unsigned alignment)
 		_align_chunk(c, alignment);
 
 	/* have we got room ? */
-	if (!c || (c->begin > c->end) || (c->end - c->begin < s)) {
+	if (!c || ((c->begin + s) > c->end)) {
 		/* allocate new chunk */
 		size_t needed = s + alignment + sizeof(struct chunk);
 		c = _new_chunk(p, (needed > p->chunk_size) ?
@@ -169,7 +169,7 @@ int dm_pool_begin_object(struct dm_pool *p, size_t hint)
 	if (c)
 		_align_chunk(c, align);
 
-	if (!c || (c->begin > c->end) || (c->end - c->begin < hint)) {
+	if (!c || ((c->begin + hint) > c->end)) {
 		/* allocate a new chunk */
 		c = _new_chunk(p,
 			       hint > (p->chunk_size - sizeof(struct chunk)) ?
@@ -192,7 +192,7 @@ int dm_pool_grow_object(struct dm_pool *p, const void *extra, size_t delta)
 	if (!delta)
 		delta = strlen(extra);
 
-	if (c->end - (c->begin + p->object_len) < delta) {
+	if ((c->begin + p->object_len + delta) > c->end) {
 		/* move into a new chunk */
 		if (p->object_len + delta > (p->chunk_size / 2))
 			nc = _new_chunk(p, (p->object_len + delta) * 2);
-- 
1.7.4.1


