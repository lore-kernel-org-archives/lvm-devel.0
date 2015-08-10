From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 10 Aug 2015 20:13:37 +0000 (UTC)
Subject: master - lvmlockd: add LV name to some debug logging
Message-ID: <20150810201337.C666460F66@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=597de9d58673f141bf21aa9db899d13ca2c97b7b
Commit:        597de9d58673f141bf21aa9db899d13ca2c97b7b
Parent:        f072a7632655d0541b56858d5fbe172fa6075e68
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 10 15:05:41 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 10 15:07:10 2015 -0500

lvmlockd: add LV name to some debug logging

The LV uuid is used as the lock name, and including
the LV name in some log messages makes it easier to
follow log messages.
---
 daemons/lvmlockd/lvmlockd-core.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 5e4e73f..86bb89b 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1022,7 +1022,10 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 	uint32_t r_version = 0;
 	int rv;
 
-	log_debug("S %s R %s res_lock mode %s", ls->name, r->name, mode_str(act->mode));
+	if (r->type == LD_RT_LV)
+		log_debug("S %s R %s res_lock mode %s (%s)", ls->name, r->name, mode_str(act->mode), act->lv_name);
+	else
+		log_debug("S %s R %s res_lock mode %s", ls->name, r->name, mode_str(act->mode));
 
 	if (r->mode == LD_LK_SH && act->mode == LD_LK_SH)
 		goto add_lk;
@@ -1284,8 +1287,12 @@ static int res_unlock(struct lockspace *ls, struct resource *r,
 	return -ENOENT;
 
 do_unlock:
-	log_debug("S %s R %s res_unlock %s", ls->name, r->name,
-		  (act->op == LD_OP_CLOSE) ? "from close" : "");
+	if (act->op == LD_OP_CLOSE)
+		log_debug("S %s R %s res_unlock from close", ls->name, r->name);
+	else if (r->type == LD_RT_LV)
+		log_debug("S %s R %s res_unlock (%s)", ls->name, r->name, act->lv_name);
+	else
+		log_debug("S %s R %s res_unlock", ls->name, r->name);
 
 	/* send unlock to lm when last sh lock is unlocked */
 	if (lk->mode == LD_LK_SH) {


