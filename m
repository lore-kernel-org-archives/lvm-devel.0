From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:45 +0100
Subject: [PATCH 13/23] Make it obvious this code is not used
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <0f996ef77ec9abd5d3fba2c9a84da9a854c154cd.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Static analyzis and lcov likes to know this code is unused.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2c2fc19..6d7d905 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -309,6 +309,7 @@ static const struct dm_info *_cached_info(struct dm_pool *mem,
 	return dinfo;
 }
 
+#if 0
 /* FIXME Interface must cope with multiple targets */
 static int _status_run(const char *name, const char *uuid,
 		       unsigned long long *s, unsigned long long *l,
@@ -386,6 +387,7 @@ static int _status(const char *name, const char *uuid,
 
 	return 0;
 }
+#endif
 
 int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 		       const char *layer, const char *target_type)
-- 
1.7.3.4


