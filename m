From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:31 +0000 (GMT)
Subject: stable-2.02 - lvconvert: more support for yes conversion
Message-ID: <20201018210231.902843850429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e5010662a19502183fcbcc2a5e755c223ede2744
Commit:        e5010662a19502183fcbcc2a5e755c223ede2744
Parent:        9c746f153e351a806592554cf1d90ddb03879933
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 8 10:57:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 18 21:27:51 2020 +0200

lvconvert: more support for yes conversion

When converting volume to pool LV use also wiping of other signatures.
For pool conversion support --yet and --force
to bypass prompting for signature wiping.

Note: currently we have lvconvert doing convertion and prompting
for confirmation of conversion - and then again wipe_lv() prompts
for removing i.e. filesystem signature - we should unify this
prompting into 1 message  - althought the 'filesystem' discovery
needs active volume - while the 1st. conversion prompt can
work without active converted volume.
---
 tools/lvconvert.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4dc2eed59..fb33cc4e8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3195,7 +3195,11 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
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


