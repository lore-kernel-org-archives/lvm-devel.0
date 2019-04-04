From: David Teigland <teigland@sourceware.org>
Date: Thu, 4 Apr 2019 14:21:17 -0400
Subject: master - lvextend: refresh shared LV without using select
Message-ID: <201904041821.x34ILHJT016810@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50800e33d56176e034970f93c5f87f59ecd569db
Commit:        50800e33d56176e034970f93c5f87f59ecd569db
Parent:        5d6fe796bd03a49b44e387dc8026996292505f27
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 4 13:19:08 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 4 13:19:08 2019 -0500

lvextend: refresh shared LV without using select

Using select instead of normal args did not end
up being a help, so remove it.
---
 daemons/lvmlockd/lvmlockd-dlm.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index ee39c3e..bfc1d23 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -818,11 +818,10 @@ int lm_refresh_lv_start_dlm(struct action *act)
 	memset(run_uuid, 0, sizeof(run_uuid));
 
 	/* todo: add --readonly */
-	/* FIXME: move vgname into the select option once the dlm can handle compound select args */
 
 	snprintf(command, DLMC_RUN_COMMAND_LEN,
-		 "lvm lvchange --refresh --partial --nolocking --select lvname=%s %s",
-		 lvname, vgname);
+		 "lvm lvchange --refresh --partial --nolocking %s/%s",
+		 vgname, lvname);
 
 	rv = dlmc_run_start(command, strlen(command), 0,
 			    DLMC_FLAG_RUN_START_NODE_NONE,


