From: Milan Broz <mbroz@redhat.com>
Date: Fri, 04 Dec 2009 16:03:32 +0100
Subject: [PATCH] Remove newly created log volume if initial deactivation fails.
In-Reply-To: <1259847079-23268-1-git-send-email-mbroz@redhat.com>
References: <1259847079-23268-1-git-send-email-mbroz@redhat.com>
Message-ID: <4B1924C4.1080002@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(this works even on cluster - this help to debug situations like in bug 538571)

Remove newly created log volume if initial deactivation fails.

If there is problem deactivate LV and
_init_mirror_log is called with remove_on_failure = 1,
remove the newly created log LV from metadata.

(This can happen if there is active device with the same name
but different UUID.)

The main reason for this "workaround" patch is to
 - do not keep _mlog volume in metadata, so user can repeat the action
 - print better error message describing the real problem
 
# (old) lvcreate -m 2 -n lv1 -l 1 --nosync vg_bar
  WARNING: New mirror won't be synchronised. Don't read what you didn't write!
  /dev/vg_bar/lv1_mlog: not found: device not cleared
  Aborting. Failed to wipe mirror log.
  Error locking on node bar-01: Input/output error
  Unable to deactivate mirror log LV. Manual intervention required.
  Failed to create mirror log.

# lvcreate -m 2 -n lv1 -l 1 --nosync vg_bar
  WARNING: New mirror won't be synchronised. Don't read what you didn't write!
  Aborting. Unable to deactivate mirror log.
  Failed to initialise mirror log.

Signed-off-by: Milan Broz <mbroz@redhat.com>

---
 lib/metadata/mirror.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index c331e0e..3d757c2 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -255,11 +255,19 @@ static int _init_mirror_log(struct cmd_context *cmd,
 
 	/* If the LV is active, deactivate it first. */
 	if (lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
-		if (!deactivate_lv(cmd, log_lv))
-			return_0;
+		(void)deactivate_lv(cmd, log_lv);
 		was_active = 1;
 	}
 
+	/* FIXME: workaround to fail early
+	 * Ensure that log is really deactivated because deactivate_lv
+	 * on cluster do not fail if there is log_lv with different UUID.
+	 */
+	if (was_active && lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
+		log_error("Aborting. Unable to deactivate mirror log.");
+		goto revert_new_lv;
+	}
+
 	/* Temporary make it visible for set_lv() */
 	lv_set_visible(log_lv);
 
@@ -1354,7 +1362,7 @@ static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 	}
 
 	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
-		log_error("Failed to create mirror log.");
+		log_error("Failed to initialise mirror log.");
 		return NULL;
 	}
 



