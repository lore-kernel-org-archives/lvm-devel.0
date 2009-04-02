From: Milan Broz <mbroz@redhat.com>
Date: Thu, 02 Apr 2009 16:19:41 +0200
Subject: [PATCH] fix debugging version of dm_pool_grow_object to properly use delta=0
Message-ID: <49D4C97D.5020304@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix debug poll grow object to properly support delta=0

(It prints garbage for some reports)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 libdm/mm/pool-debug.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/libdm/mm/pool-debug.c b/libdm/mm/pool-debug.c
index 911f8e2..fd13c1b 100644
--- a/libdm/mm/pool-debug.c
+++ b/libdm/mm/pool-debug.c
@@ -220,6 +220,9 @@ int dm_pool_grow_object(struct dm_pool *p, const void *extra, size_t delta)
 	struct block *new;
 	size_t size = delta ? : strlen(extra);
 
+	if (!delta)
+		delta = size;
+
 	assert(p->begun);
 
 	if (p->object)



