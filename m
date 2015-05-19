From: okozina <okozina@fedoraproject.org>
Date: Tue, 19 May 2015 19:02:57 +0000 (UTC)
Subject: master - lvconvert.c: call find_lv directly
Message-ID: <20150519190257.ACDAD60FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08114840caf0a31d76b8870ec96594dd715baff0
Commit:        08114840caf0a31d76b8870ec96594dd715baff0
Parent:        0d300b70f911beacf099daa3950e1e77c30f27c2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 19 14:50:58 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 19 20:55:57 2015 +0200

lvconvert.c: call find_lv directly

---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 48a4711..7267c2f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3259,7 +3259,7 @@ static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context
 		return_NULL;
 	}
 
-	if (!(lv = poll_get_copy_lv(cmd, vg, lv_name, NULL, 0))) {
+	if (!(lv = find_lv(vg, lv_name))) {
 		log_error("Can't find LV %s in VG %s", lv_name, vg_name);
 		unlock_and_release_vg(cmd, vg, vg_name);
 		return NULL;


