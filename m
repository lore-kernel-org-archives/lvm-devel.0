From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:24 +0100
Subject: [PATCH 20/29] Add test for lv_name not NULL
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <21bdad389ed809525bc1fc06683b692e363a6402.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This test is in fact not really needed - as the calculation of the
strlen(vgname) will be different from (lv_name - vg_name) when lv_name is
NULL - but IMHO it's logical to not make this evaluation -
and also static analysis is more straighforward when lv_name pointer
is guaranteed to be non NULL.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index f6ba45b..9be9936 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -331,7 +331,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 				tags_arg = NULL;
 				dm_list_init(&lvnames);
 				break;
-			} else if (!strncmp(vg_name, vgname, strlen(vgname)) &&
+			} else if (!strncmp(vg_name, vgname, strlen(vgname)) && lv_name &&
 				   strlen(vgname) == (size_t) (lv_name - vg_name)) {
 				if (!str_list_add(cmd->mem, &lvnames,
 						  dm_pool_strdup(cmd->mem,
-- 
1.7.3.2


