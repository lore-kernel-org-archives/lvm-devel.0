From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  8 Jul 2015 20:27:33 +0000 (UTC)
Subject: master - lvmlockd: remove log_error instances for normal conditions
Message-ID: <20150708202733.498EB60DD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=903569d53375f8305bcfb8c2a0e9af7c29fa1d46
Commit:        903569d53375f8305bcfb8c2a0e9af7c29fa1d46
Parent:        d77546773bfe0dd2db98427d6b5b16fa4f19e47a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 8 13:23:48 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 8 15:25:14 2015 -0500

lvmlockd: remove log_error instances for normal conditions

There are a number of log_error instances that are replaced
by log_debug because they are not errors.
---
 daemons/lvmlockd/lvmlockd-core.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 73a2fb3..1b7f494 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1850,10 +1850,16 @@ static int clear_locks(struct lockspace *ls, int free_vg)
 		list_for_each_entry_safe(lk, lk_safe, &r->locks, list) {
 			lk_count++;
 
+			/*
+			 * Stopping a lockspace shouldn't happen with LV locks
+			 * still held, but it will be stopped with GL and VG
+			 * locks held.
+			 */
+
 			if (lk->flags & LD_LF_PERSISTENT)
 				log_error("S %s R %s clear lock persistent", ls->name, r->name);
 			else
-				log_error("S %s R %s clear lock client %d", ls->name, r->name, lk->client_id);
+				log_debug("S %s R %s clear lock mode %s client %d", ls->name, r->name, mode_str(lk->mode), lk->client_id);
 
 			if (lk->version > lk_version)
 				lk_version = lk->version;
@@ -2356,17 +2362,14 @@ static int vg_ls_name(const char *vg_name, char *ls_name)
 
 /* FIXME: add mutex for gl_lsname_ ? */
 
-static int gl_ls_name(char *ls_name)
+static void gl_ls_name(char *ls_name)
 {
 	if (gl_use_dlm)
 		memcpy(ls_name, gl_lsname_dlm, MAX_NAME);
 	else if (gl_use_sanlock)
 		memcpy(ls_name, gl_lsname_sanlock, MAX_NAME);
-	else {
-		log_error("gl_ls_name: global lockspace type unknown");
-		return -1;
-	}
-	return 0;
+	else
+		memset(ls_name, 0, MAX_NAME);
 }
 
 /*
@@ -3482,7 +3485,8 @@ static int add_lock_action(struct action *act)
 		int ls_inactive = 0;
 		int ls_create_fail = 0;
 
-		ls = find_lockspace_inactive(ls_name);
+		if (ls_name[0])
+			ls = find_lockspace_inactive(ls_name);
 		if (ls) {
 			ls_inactive = 1;
 			ls_create_fail = ls->create_fail;
@@ -3496,7 +3500,7 @@ static int add_lock_action(struct action *act)
 
 		} else if (act->flags & LD_AF_SEARCH_LS) {
 			/* fail if we've already tried searching for the ls */
-			log_error("lockspace search repeated %s", ls_name);
+			log_debug("lockspace search repeated %s", ls_name);
 			return -ENOLS;
 
 		} else if (act->op == LD_OP_LOCK && act->rt == LD_RT_GL && gl_use_sanlock) {
@@ -3528,7 +3532,7 @@ static int add_lock_action(struct action *act)
 			return -ENOLS;
 
 		} else {
-			log_error("lockspace not found %s", ls_name);
+			log_debug("lockspace not found %s", ls_name);
 			return -ENOLS;
 		}
 	}


