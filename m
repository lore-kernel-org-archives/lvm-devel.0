From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:25 +0100
Subject: [PATCH 21/29] Instrument with nonnull dev_manager_transient
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <5f41ba3ce7405e6049ead308613062eae67e4171.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As the function directly dereferencies its parameters mark them as non-null.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index be6de51..72ca7f9 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -58,7 +58,7 @@ int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv, unsi
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
 			unsigned origin_only, int *flush_required);
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
-int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv);
+int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv) __attribute__((nonnull(1, 2)));
 
 int dev_manager_mknodes(const struct logical_volume *lv);
 
-- 
1.7.3.2


