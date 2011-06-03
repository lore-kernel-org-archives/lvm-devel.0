From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:24 +0200
Subject: [PATCH 06/11] FIXME - remove test for status flag
In-Reply-To: <cover.1307127169.git.zkabelac@redhat.com>
References: <cover.1307127169.git.zkabelac@redhat.com>
Message-ID: <0ceefea577b34491bd5f4fd4fb09052361b60759.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As the ACTIVATE_EXCL could be set only in clvmd code - there is no
use for this test in lv_add_mirrors() function only called from
tools context.

FIXME: Add cluster test case for this.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/mirror.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 21a10bf..4e9f254 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -2005,8 +2005,7 @@ int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (vg_is_clustered(lv->vg)) {
 		/* FIXME: review check of lv_is_active_remotely */
-		if (!(lv->status & ACTIVATE_EXCL) &&
-		    !cluster_mirror_is_available(lv)) {
+		if (!cluster_mirror_is_available(lv)) {
 			log_error("Shared cluster mirrors are not available.");
 			return 0;
 		}
-- 
1.7.5.2


