From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 26 Jun 2009 05:33:13 -0400
Subject: [PATCH 5/6] Don't segfault in vg_release when vg->cmd is NULL.
In-Reply-To: <1246008794-30493-5-git-send-email-dwysocha@redhat.com>
References: <1246008794-30493-1-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-2-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-3-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-4-git-send-email-dwysocha@redhat.com>
	<1246008794-30493-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1246008794-30493-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Petr Rockai <prockai@redhat.com>

Sun May  3 13:06:14 CEST 2009  Petr Rockai <me@mornfall.net>
  * Don't segfault in vg_release when vg->cmd is NULL.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 14ca01b..3638ebe 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2165,7 +2165,7 @@ void vg_release(struct volume_group *vg)
 	if (!vg || !vg->vgmem)
 		return;
 
-	if (vg->vgmem == vg->cmd->mem)
+	if (vg->cmd && vg->vgmem == vg->cmd->mem)
 		log_error("Internal error: global memory pool used for VG %s",
 			  vg->name);
 
-- 
1.6.0.6


