From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 May 2014 10:02:23 +0000 (UTC)
Subject: master - cleanup: use y/n instead of y|n
Message-ID: <20140522100223.217B6611E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=496953fb3915a7a985558a7a1b2edf534e170dfd
Commit:        496953fb3915a7a985558a7a1b2edf534e170dfd
Parent:        1c4fe47308e3638b95f042a1efc942c5ce8e4fdc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 22 11:57:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 22 12:01:43 2014 +0200

cleanup: use y/n instead of y|n

Use same for of yes no query everywhere.
---
 man/fsadm.8.in    |    2 +-
 tools/lvconvert.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/fsadm.8.in b/man/fsadm.8.in
index 46be1ff..20ec4c8 100644
--- a/man/fsadm.8.in
+++ b/man/fsadm.8.in
@@ -55,7 +55,7 @@ A status code of 1 is used for other failures.
 Resize the filesystem on logical volume /dev/vg/test to 1000 megabytes.
 If /dev/vg/test contains ext2/ext3/ext4
 filesystem it will be unmounted prior the resize.
-All [y|n] questions will be answered 'y'.
+All [y/n] questions will be answered 'y'.
 .sp
 .B fsadm \-e \-y resize /dev/vg/test 1000M
 .SH ENVIRONMENT VARIABLES
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 79f2be5..82ce360 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2721,7 +2721,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
 
 	if (!lp->yes &&
-	    yes_no_prompt("Do you really want to convert \"%s/%s\"? [y|n]: ",
+	    yes_no_prompt("Do you really want to convert \"%s/%s\"? [y/n]: ",
 			  pool_lv->vg->name, pool_lv->name) == 'n') {
 		log_error("Conversion aborted.");
 		return 0;
@@ -2839,7 +2839,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
 
 		if (!lp->yes &&
-		    yes_no_prompt("Do you really want to convert \"%s/%s\"? [y|n]: ",
+		    yes_no_prompt("Do you really want to convert \"%s/%s\"? [y/n]: ",
 				  metadata_lv->vg->name, metadata_lv->name) == 'n') {
 			log_error("Conversion aborted.");
 			return 0;


