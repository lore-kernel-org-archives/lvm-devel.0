From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 May 2015 15:22:24 +0000 (UTC)
Subject: master - lvmpolld-client.c: use lvmpolld debug class where appropriate
Message-ID: <20150512152224.EF18460403@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8da7915222ecb8d9f6c1012caca3957e6c2306ca
Commit:        8da7915222ecb8d9f6c1012caca3957e6c2306ca
Parent:        2ec51e6185ba84578fbe314ba96be8b7d0f18bdc
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 12 16:28:42 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 12 17:17:00 2015 +0200

lvmpolld-client.c: use lvmpolld debug class where appropriate

---
 lib/lvmpolld/lvmpolld-client.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
index d03a650..91f77eb 100644
--- a/lib/lvmpolld/lvmpolld-client.c
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -263,18 +263,22 @@ int lvmpolld_poll_init(const struct cmd_context *cmd, const struct poll_operatio
 	}
 
 	if (parms->lv_type & PVMOVE) {
-		log_verbose("lvmpolld: Requesting pvmove%s", parms->aborting ? " abort." : ".");
+		log_debug_lvmpolld("Asking lvmpolld for pvmove%s on %s/%s.",
+				   parms->aborting ? " abort" : "", id->vg_name, id->lv_name);
 		r =  _process_poll_init(cmd, LVMPD_REQ_PVMOVE, id, parms);
 	} else if (parms->lv_type & CONVERTING) {
-		log_verbose("lvmpolld: Requesting convert mirror.");
+		log_debug_lvmpolld("Asking lvmpolld for mirror conversion on %s/%s.",
+				   id->vg_name, id->lv_name);
 		r =  _process_poll_init(cmd, LVMPD_REQ_CONVERT, id, parms);
 	} else if (parms->lv_type & MERGING) {
 		if (parms->lv_type & SNAPSHOT) {
-			log_verbose("lvmpolld: Requesting snapshot merge.");
+			log_debug_lvmpolld("Asking lvmpolld for snapshot merge on %s/%s.",
+					   id->vg_name, id->lv_name);
 			r =  _process_poll_init(cmd, LVMPD_REQ_MERGE, id, parms);
 		}
 		else if (parms->lv_type & THIN_VOLUME) {
-			log_verbose("lvmpolld: Thin snapshot merge.");
+			log_debug_lvmpolld("Asking lvmpolld for thin snapshot merge on %s/%s.",
+					   id->vg_name, id->lv_name);
 			r = _process_poll_init(cmd, LVMPD_REQ_MERGE_THIN, id, parms);
 		}
 		else {


