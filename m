From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  8 Jul 2020 09:45:25 +0000 (GMT)
Subject: master - lvconvert: more support for yes conversion
Message-ID: <20200708094525.24314385E444@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b7f3667ce20b731bbda9b1d61df49abbcd1bd20e
Commit:        b7f3667ce20b731bbda9b1d61df49abbcd1bd20e
Parent:        fe78cd4082cb9af10580180d61898fcef93dc624
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 8 10:57:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 8 11:37:33 2020 +0200

lvconvert: more support for yes conversion

When converting volume to pool LV use also wiping of other signatures.
For writecache & pool conversion support --yet and --force
to bypass prompting for signature wiping.
For writecache drop unneded zero_sectors.

Note: currently we have lvconvert doing convertion and prompting
for confirmation of conversion - and then again wipe_lv() prompts
for removing i.e. filesystem signature - we should unify this
prompting into 1 message  - althought the 'filesystem' discovery
needs active volume - while the 1st. conversion prompt can
work without active converted volume.
---
 tools/lvconvert.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 61256c698..0dcc77689 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3279,7 +3279,11 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			}
 			metadata_lv->status &= ~LV_ACTIVATION_SKIP;
 
-			if (!wipe_lv(metadata_lv, (struct wipe_params) { .do_zero = 1 })) {
+			if (!wipe_lv(metadata_lv, (struct wipe_params) {
+						  .do_wipe_signatures = 1,
+						  .is_metadata = 1,
+						  .yes = arg_count(cmd, yes_ARG),
+						  .force = arg_count(cmd, force_ARG) } )) {
 				log_error("Aborting. Failed to wipe metadata lv.");
 				goto bad;
 			}
@@ -5502,7 +5506,8 @@ static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
 	struct wipe_params wp = {
 		.do_wipe_signatures = 1, /* optional, to print warning if clobbering something */
 		.do_zero = 1,            /* required for dm-writecache to work */
-		.zero_sectors = 1
+		.yes = arg_count(cmd, yes_ARG),
+		.force = arg_count(cmd, force_ARG)
 	};
 	int ret;
 


