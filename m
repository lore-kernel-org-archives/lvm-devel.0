From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 12 Apr 2019 15:38:38 -0400
Subject: stable-2.02 - lvconvert: can't create cachepool with RAID1 metadata SubLV
Message-ID: <201904121938.x3CJccXH012052@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=699bf8609049058875d84f129d508d4ccbed3900
Commit:        699bf8609049058875d84f129d508d4ccbed3900
Parent:        03d6cfdd99fb1c2fd85721ab6faebbb1b6658873
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Apr 12 21:27:30 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Apr 12 21:38:04 2019 +0200

lvconvert: can't create cachepool with RAID1 metadata SubLV

Trying to convert an exiting RAID1 LV to cache metadata SubLV
fails because of missing exclusive activation during wiping.

Solve by activating the RAID1 metadata SubLV exclusively.

Resolves: rhbz1698866
---
 tools/lvconvert.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2b3c3ea..bc666c0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3167,8 +3167,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 		if (zero_metadata) {
 			metadata_lv->status |= LV_ACTIVATION_SKIP;
-			if (!activate_lv(cmd, metadata_lv)) {
-				log_error("Aborting. Failed to activate metadata lv.");
+			if (!activate_lv_excl_local(cmd, metadata_lv)) {
+				log_error("Aborting. Failed to locally activate metadata lv.");
 				goto bad;
 			}
 			metadata_lv->status &= ~LV_ACTIVATION_SKIP;


