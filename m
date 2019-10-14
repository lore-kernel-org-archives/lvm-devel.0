From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:21:40 -0400
Subject: master - lvconvert: use struct initializer
Message-ID: <201910141321.x9EDLeZg018717@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ddaf2002c94a33863ef7adf69ad4cdffcfbd73c5
Commit:        ddaf2002c94a33863ef7adf69ad4cdffcfbd73c5
Parent:        e6691aa04be8bbe8768c6a7a520b36498066b9e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 14 11:53:59 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:13:47 2019 +0200

lvconvert: use struct initializer

Always good to keep rest of structure initilized with zeros.
---
 tools/lvconvert.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index caef5d5..8ecbf34 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5290,7 +5290,11 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 
 static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	struct wipe_params wp;
+	struct wipe_params wp = {
+		.do_wipe_signatures = 1, /* optional, to print warning if clobbering something */
+		.do_zero = 1,            /* required for dm-writecache to work */
+		.zero_sectors = 1
+	};
 	int ret;
 
 	if (!activate_lv(cmd, lv)) {
@@ -5298,11 +5302,6 @@ static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 	}
 
-	wp.do_wipe_signatures = 1; /* optional, to print warning if clobbering something */
-	wp.do_zero = 1;            /* required for dm-writecache to work */
-	wp.zero_sectors = 1;
-	wp.zero_value = 0;
-
 	ret = wipe_lv(lv, wp);
 
 	if (!deactivate_lv(cmd, lv)) {


