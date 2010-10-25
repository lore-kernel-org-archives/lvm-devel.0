From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:16 +0200
Subject: [PATCH 09/30] Reuse result of previous strchr.
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <1ded298d3c909b9ebdcedcf9c275c201c9e4861c.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clang Argument with 'nonnull' attribute passed null
Reuse result of the last strchr call - it also makes sure,
'st' point is nonnull for next strchr call.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 02c4962..5adc160 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -869,7 +869,7 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 			while (*st == '/')
 				st++;
 
-		if (!strchr(vg_name, '/') || strchr(st, '/')) {
+		if (!st || strchr(st, '/')) {
 			log_error("\"%s\": Invalid path for Logical Volume",
 				  lv_name);
 			return 0;
-- 
1.7.3.1


