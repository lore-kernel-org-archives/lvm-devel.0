From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:23 +0200
Subject: [PATCH 05/11] FIXME
In-Reply-To: <cover.1307127169.git.zkabelac@redhat.com>
References: <cover.1307127169.git.zkabelac@redhat.com>
Message-ID: <959b530681887b5c15e8a8c516aff1292c057759.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c |    4 +++-
 lib/metadata/mirror.c   |    1 +
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4fd9c6a..58f623e 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -783,12 +783,14 @@ static int _lv_is_active(struct logical_volume *lv,
 		goto out;
 	}
 
+	/* FIXME: Is this fallback alright? */
 	if (activate_lv_excl(lv->vg->cmd, lv)) {
 		if (!deactivate_lv(lv->vg->cmd, lv))
 			stack;
+		/* FIXME: locally & exclusive are undefined. */
 		return 0;
 	}
-
+	/* FIXME: Check exclusive value here. */
 out:
 	if (locally)
 		*locally = l;
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index b02c7bb..21a10bf 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -2004,6 +2004,7 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (vg_is_clustered(lv->vg)) {
+		/* FIXME: review check of lv_is_active_remotely */
 		if (!(lv->status & ACTIVATE_EXCL) &&
 		    !cluster_mirror_is_available(lv)) {
 			log_error("Shared cluster mirrors are not available.");
-- 
1.7.5.2


