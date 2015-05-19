From: okozina <okozina@fedoraproject.org>
Date: Tue, 19 May 2015 19:02:53 +0000 (UTC)
Subject: master - lvconvert.c: call vg_read directly
Message-ID: <20150519190253.7679F60FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15939e34353cc4bb89e674eac5b51a32fbd094e9
Commit:        15939e34353cc4bb89e674eac5b51a32fbd094e9
Parent:        131c657735d3a315ceb9f072cb9a9591d363fa78
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 19 14:07:04 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 19 20:55:41 2015 +0200

lvconvert.c: call vg_read directly

---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5b2ab65..48a4711 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3253,7 +3253,7 @@ static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context
 	struct volume_group *vg;
 	struct logical_volume* lv = NULL;
 
-	vg = poll_get_copy_vg(cmd, vg_name, NULL, READ_FOR_UPDATE);
+	vg = vg_read(cmd, vg_name, NULL, READ_FOR_UPDATE);
 	if (vg_read_error(vg)) {
 		release_vg(vg);
 		return_NULL;


