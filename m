From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 26 May 2009 12:52:28 -0400
Subject: [PATCH] Fix CLUSTERED flag in new _vg_read_for_update() and vg_read().
Message-ID: <1243356748-22653-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In the new _vg_read_for_update(), we always do the check for CLUSTERED vg
status flag after reading the volume group.  Thus, no need to set the flag
in vg_read() or clear it later before calling _vg_bad_status_bits().

Also, add back in the !lockingfailed() as part of the CLUSTERED flag check.
It's unclear why it was removed when the check was moved from
_vg_bad_status_bits() to inside _vg_lock_and_read().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f16cd55..55c4578 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2763,7 +2763,8 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 		goto_bad;
 	}
 
-	if (vg_is_clustered(vg) && !locking_is_clustered()) {
+	if ((vg_is_clustered(vg)) && !locking_is_clustered() &&
+	    !lockingfailed()) {
 		log_error("Skipping clustered volume group %s", vg->name);
 		failure |= FAILED_CLUSTERED;
 		goto_bad;
@@ -2779,9 +2780,8 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 			goto_bad;
 		}
 	}
-	
 
-	failure |= _vg_bad_status_bits(vg, status_flags & ~CLUSTERED);
+	failure |= _vg_bad_status_bits(vg, status_flags);
 	if (failure)
 		goto_bad;
 
@@ -2828,7 +2828,7 @@ bad:
 vg_t *vg_read(struct cmd_context *cmd, const char *vg_name,
 	      const char *vgid, uint32_t flags)
 {
-	uint32_t status = CLUSTERED;
+	uint32_t status = 0;
 	uint32_t lock_flags = LCK_VG_READ;
 
 	if (flags & READ_FOR_UPDATE) {
-- 
1.6.0.6


