From: David Teigland <teigland@sourceware.org>
Date: Fri, 22 Mar 2019 16:04:15 -0400
Subject: master - lvextend: refresh shared LV with vgname as arg
Message-ID: <201903222004.x2MK4FZT003271@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=27cfeb1d39b2515b9c4b81a1d217e05ae954a68b
Commit:        27cfeb1d39b2515b9c4b81a1d217e05ae954a68b
Parent:        86b96ede2af32404d0b7b5f516a35dafc4da442e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 22 15:01:29 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 22 15:01:29 2019 -0500

lvextend: refresh shared LV with vgname as arg

Update the previous commit to leave the vgname as
an arg instead of moving it into the select option,
(the compound select option rule is confusing the
dlm arg processing.)
---
 daemons/lvmlockd/lvmlockd-dlm.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 21aaa2d..ee39c3e 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -818,9 +818,10 @@ int lm_refresh_lv_start_dlm(struct action *act)
 	memset(run_uuid, 0, sizeof(run_uuid));
 
 	/* todo: add --readonly */
+	/* FIXME: move vgname into the select option once the dlm can handle compound select args */
 
 	snprintf(command, DLMC_RUN_COMMAND_LEN,
-		 "lvm lvchange --refresh --partial --nolocking --select 'lvname=%s && vgname=%s'",
+		 "lvm lvchange --refresh --partial --nolocking --select lvname=%s %s",
 		 lvname, vgname);
 
 	rv = dlmc_run_start(command, strlen(command), 0,


