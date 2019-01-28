From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jan 2019 16:40:47 -0500
Subject: master - lvconvert: pass force and yes options for vdo conversion
Message-ID: <201901282140.x0SLelrp002434@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b64021ee5f7dfb25ca99921992fef3aa89ce7c4c
Commit:        b64021ee5f7dfb25ca99921992fef3aa89ce7c4c
Parent:        ab1fd0cb37b75311e1ec4e13bbaea4a214b43285
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 23 22:51:24 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 28 22:17:27 2019 +0100

lvconvert: pass force and yes options for vdo conversion

---
 tools/lvconvert.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8ea7b65..9fa87c0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5017,7 +5017,9 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 		goto out;
 	}
 
-	if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .do_wipe_signatures = 1 })) {
+	if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .do_wipe_signatures = 1,
+		     .yes = arg_count(cmd, yes_ARG),
+		     .force = arg_count(cmd, force_ARG)})) {
 		log_error("Aborting. Failed to wipe VDO data store.");
 		goto out;
 	}


