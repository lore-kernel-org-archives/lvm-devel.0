From: Milan Broz <mbroz@redhat.com>
Date: Thu,  3 Dec 2009 14:31:19 +0100
Subject: [PATCH] Remove newly created log volume if initial deactivation fails.
Message-ID: <1259847079-23268-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If there is problem deactivate LV and
_init_mirror_log is called with remove_on_failure = 1,
remove the newly created log LV from metadata.

(This can happen if there is active device with the same name
but different UUID.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/mirror.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index c331e0e..4c24058 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -256,7 +256,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
 	/* If the LV is active, deactivate it first. */
 	if (lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
 		if (!deactivate_lv(cmd, log_lv))
-			return_0;
+			goto revert_new_lv;
 		was_active = 1;
 	}
 
@@ -1354,7 +1354,7 @@ static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 	}
 
 	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
-		log_error("Failed to create mirror log.");
+		log_error("Failed to initialise mirror log.");
 		return NULL;
 	}
 
-- 
1.6.5.3


