From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 26 Oct 2010 14:59:23 +0200
Subject: [PATCH 2/5] Ensure seg is nonnull
In-Reply-To: <cover.1288097372.git.zkabelac@redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
Message-ID: <fcd9985806b259f3f056c9f473144e029b2b7c8a.1288097372.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clang Logic error	Dereference of null pointer
Make sure we do not try to use NULL seg pointer.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index cbb5378..cc67a60 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -626,6 +626,11 @@ int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv)
 		if (!type || !params)
 			continue;
 
+		if (!seg) {
+			log_error(INTERNAL_ERROR "Segment is not selected.");
+			goto out;
+		}
+
 		if (seg->segtype->ops->check_transient_status &&
 		    !seg->segtype->ops->check_transient_status(seg, params))
 			goto_out;
-- 
1.7.3.2


