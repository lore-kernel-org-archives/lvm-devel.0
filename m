From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  8 Jul 2013 12:04:01 +0000 (UTC)
Subject: master - cleanup: use arg value
Message-ID: <20130708120401.46CD76034E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5d253f3150eb10f24accb8d750f1efbf9d0a904
Commit:        c5d253f3150eb10f24accb8d750f1efbf9d0a904
Parent:        1b4f888bc5be23563167eb056582e7567b832f0b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 6 19:40:09 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 8 14:01:41 2013 +0200

cleanup: use arg value

Use defined ARG_COUNT for the last element
---
 tools/vgchange.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index e55c404..d3e93f2 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -447,9 +447,9 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute__((unused)))
 {
-	int i;
+	unsigned i;
 
-	static struct {
+	static const struct {
 		int arg;
 		int (*fn)(struct cmd_context *cmd, struct volume_group *vg);
 	} _vgchange_args[] = {
@@ -465,7 +465,6 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		{ vgmetadatacopies_ARG, &_vgchange_metadata_copies },
 		{ profile_ARG, &_vgchange_profile},
 		{ detachprofile_ARG, &_vgchange_profile},
-		{ -1, NULL },
 	};
 
 	if (vg_is_exported(vg)) {
@@ -486,7 +485,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 						arg_int_value(cmd, poll_ARG,
 						DEFAULT_BACKGROUND_POLLING));
 
-	for (i = 0; _vgchange_args[i].arg >= 0; i++) {
+	for (i = 0; i < DM_ARRAY_SIZE(_vgchange_args); ++i) {
 		if (arg_count(cmd, _vgchange_args[i].arg)) {
 			if (!archive(vg))
 				return_ECMD_FAILED;


