From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Feb 2020 17:00:31 -0500
Subject: master - pvmove: prevent moving writecache device
Message-ID: <31967.120020317002401425@us-mta-107.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1ee6f0eef24a44cc02ec941f560bc17ac61b3d8
Commit:        c1ee6f0eef24a44cc02ec941f560bc17ac61b3d8
Parent:        379a7e1288a5e7a15cd2872c074b219992575b4d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 3 15:59:12 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 3 15:59:12 2020 -0600

pvmove: prevent moving writecache device

---
 tools/pvmove.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 674decf..0419a3d 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -376,6 +376,11 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			return NULL;
 		}
 
+		if (lv_is_writecache_cachevol(lv)) {
+			log_error("Unable to pvmove device used for writecache.");
+			return NULL;
+		}
+
 		seg = first_seg(lv);
 		if (!needs_exclusive) {
 			/* Presence of exclusive LV decides whether pvmove must be also exclusive */
@@ -615,6 +620,11 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 			log_error("Logical volume %s not found.", lv_name);
 			return ECMD_FAILED;
 		}
+
+		if (lv_is_writecache(lv)) {
+			log_error("pvmove not allowed on LV using writecache.");
+			return ECMD_FAILED;
+		}
 	}
 
 	/*



