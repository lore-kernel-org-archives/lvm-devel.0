From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:35:53 +0100
Subject: [PATCH 2/6] Intialize cmd in the struct alloc_handle
In-Reply-To: <cover.1263389392.git.zkabelac@redhat.com>
References: <cover.1263389392.git.zkabelac@redhat.com>
Message-ID: <274c0318317532443449c078aaa3d2a84c274744.1263389392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move initialization of the 'cmd' member of the struct alloc_handle
before the first potentional return.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 57c3d08..e54c453 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -566,11 +566,11 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 		return NULL;
 	}
 
+	ah->cmd = cmd;
+
 	if (segtype_is_virtual(segtype))
 		return ah;
 
-	ah->cmd = cmd;
-
 	if (!(ah->mem = dm_pool_create("allocation", 1024))) {
 		log_error("allocation pool creation failed");
 		return NULL;
-- 
1.6.6


