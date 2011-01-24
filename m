From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:36 +0100
Subject: [PATCH 12/15] Skip compilation of debug code
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <c51078bbd464b5637449b21314bd03caac71f08f.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When it's not in use - do not compile this code.
Improves code coverage results.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/mm/dbg_malloc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index db7f5f3..5f06d1e 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -15,6 +15,8 @@
 
 #include "dmlib.h"
 
+#ifdef DEBUG_MEM
+
 #include <assert.h>
 #include <stdarg.h>
 
@@ -249,6 +251,8 @@ void dm_bounds_check_debug(void)
 	}
 }
 
+#endif
+
 void *dm_malloc_aux(size_t s, const char *file __attribute__((unused)),
 		    int line __attribute__((unused)))
 {
-- 
1.7.3.5


