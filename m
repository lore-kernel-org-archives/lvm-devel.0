From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:46:51 -0500
Subject: master - pvmove: better check for exclusive LV
Message-ID: <201801171346.w0HDkpgm030037@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5a961d3411c8c11312d2998378277efc8988fc7f
Commit:        5a961d3411c8c11312d2998378277efc8988fc7f
Parent:        7c6fb63041cd5c1fb899cc468d0a5cf23a01abbe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 12 15:59:07 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:44:33 2018 +0100

pvmove: better check for exclusive LV

---
 tools/pvmove.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 39cf25f..9bbe12b 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -451,7 +451,9 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		}
 
 		if (vg_is_clustered(vg) &&
-		    lv_is_active_exclusive_remotely(lv)) {
+		    lv_is_visible(lv) &&
+		    lv_is_active(lv) &&
+		    !lv_is_active_exclusive_locally(lv)) {
 			lv_skipped = 1;
 			log_print_unless_silent("Skipping LV %s which is activated "
 						"exclusively on remote node.", lv->name);


