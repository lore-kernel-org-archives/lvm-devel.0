From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Feb 2020 11:22:35 -0500
Subject: master - writecache: fix return value
Message-ID: <55415.120020711223100587@us-mta-385.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b756cb3e49b762b3a5160f9748aeb5bf995ae80e
Commit:        b756cb3e49b762b3a5160f9748aeb5bf995ae80e
Parent:        96985b1373d58b411a80c2985f348466e78cbe6e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 7 10:21:07 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 7 10:21:07 2020 -0600

writecache: fix return value

---
 tools/lvconvert.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f6a329b..a83b019 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5580,13 +5580,13 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 
 	if (!seg_is_linear(first_seg(lv_fast))) {
 		log_error("LV %s must be linear to use as a writecache.", display_lvname(lv_fast));
-		return 0;
+		goto bad;
 	}
 
 	/* fast LV shouldn't generally be active by itself, but just in case. */
 	if (lv_info(cmd, lv_fast, 1, NULL, 0, 0)) {
 		log_error("LV %s must be inactive to attach.", display_lvname(lv_fast));
-		return 0;
+		goto bad;
 	}
 
 	memset(&settings, 0, sizeof(settings));
@@ -5594,13 +5594,13 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 
 	if (!_get_writecache_settings(cmd, &settings, &block_size_sectors)) {
 		log_error("Invalid writecache settings.");
-		return 0;
+		goto bad;
 	}
 
 	if (!arg_is_set(cmd, yes_ARG) &&
 	    yes_no_prompt("Erase all existing data on %s? [y/n]: ", display_lvname(lv_fast)) == 'n') {
 		log_error("Conversion aborted.");
-		return 0;
+		goto bad;
 	}
 
 	/* Ensure the two LVs are not active elsewhere. */



