From: Tony Asleson <tasleson@redhat.com>
Date: Mon,  1 Apr 2013 16:35:01 -0500
Subject: [PATCH 7/7] config_def_check: Fix memory leak
In-Reply-To: <1364852101-14961-1-git-send-email-tasleson@redhat.com>
References: <1364852101-14961-1-git-send-email-tasleson@redhat.com>
Message-ID: <1364852101-14961-7-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There is no need to strdup a key when inserting into
the hash table as the table allocates memory and copies
the string.  This was causing memory to be lost.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/config/config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 009eb5f..2c77f30 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -577,7 +577,7 @@ int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_
 				cmd->cft_def_hash = NULL;
 				r = 0; goto out;
 			}
-			dm_hash_insert(cmd->cft_def_hash, dm_strdup(vp), def);
+			dm_hash_insert(cmd->cft_def_hash, vp, def);
 		}
 	}
 
-- 
1.8.1.4


