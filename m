From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:14 +0200
Subject: [PATCH 07/30] Ensure seg is nonnull
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <afaeb1ba5334b0f63fd3b92bc78c2f7fa577cff5.1287994529.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clang Logic error	Dereference of null pointer
Make sure we do not try to use NULL seg pointer.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index aab0c9a..216b042 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -615,7 +615,7 @@ int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv)
 		if (!type || !params)
 			continue;
 
-		if (seg->segtype->ops->check_transient_status &&
+		if (seg && seg->segtype->ops->check_transient_status &&
 		    !seg->segtype->ops->check_transient_status(seg, params))
 			goto_out;
 
-- 
1.7.3.1


