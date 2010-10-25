From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:33 +0200
Subject: [PATCH 26/30] Use static
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <be53da7626bf9a4d05bdc2f8819d9e283516478f.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/mm/pool-fast.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index d9030cf..ebd982e 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -33,8 +33,8 @@ struct dm_pool {
 	unsigned object_alignment;
 };
 
-void _align_chunk(struct chunk *c, unsigned alignment);
-struct chunk *_new_chunk(struct dm_pool *p, size_t s);
+static void _align_chunk(struct chunk *c, unsigned alignment);
+static struct chunk *_new_chunk(struct dm_pool *p, size_t s);
 static void _free_chunk(struct chunk *c);
 
 /* by default things come out aligned for doubles */
@@ -240,12 +240,12 @@ void dm_pool_abandon_object(struct dm_pool *p)
 	p->object_alignment = DEFAULT_ALIGNMENT;
 }
 
-void _align_chunk(struct chunk *c, unsigned alignment)
+static void _align_chunk(struct chunk *c, unsigned alignment)
 {
 	c->begin += alignment - ((unsigned long) c->begin & (alignment - 1));
 }
 
-struct chunk *_new_chunk(struct dm_pool *p, size_t s)
+static struct chunk *_new_chunk(struct dm_pool *p, size_t s)
 {
 	struct chunk *c;
 
-- 
1.7.3.1


