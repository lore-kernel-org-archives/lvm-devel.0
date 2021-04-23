From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:56 +0000 (GMT)
Subject: main - cov: check return value
Message-ID: <20210423210556.4386E393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b3dcd754ff99987661c47ce57a660bfcfed3ffb
Commit:        2b3dcd754ff99987661c47ce57a660bfcfed3ffb
Parent:        86a3a0c76543d377194d4e86ea31a1a4184e0dc6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 17:00:45 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: check return value

Log problems on fail path.
---
 daemons/dmeventd/dmeventd.c | 3 ++-
 lib/metadata/lv_manip.c     | 6 ++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 4c3ef74f1..041718c7a 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1742,7 +1742,8 @@ static void _init_thread_signals(void)
 	sigset_t my_sigset;
 	struct sigaction act = { .sa_handler = _sig_alarm };
 
-	sigaction(SIGALRM, &act, NULL);
+	if (sigaction(SIGALRM, &act, NULL))
+		log_sys_debug("sigaction", "SIGLARM");
 	sigfillset(&my_sigset);
 
 	/* These are used for exiting */
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cb6f09362..508f78c13 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6821,7 +6821,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 					display_lvname(pool_lv));
 	}
 
-	lockd_lv(cmd, lock_lv, "un", LDLV_PERSISTENT);
+	if (!lockd_lv(cmd, lv, "un", LDLV_PERSISTENT))
+		log_warn("WARNING: Failed to unlock %s.", display_lvname(lv));
 	lockd_free_lv(cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args);
 
 	if (!suppress_remove_message && (visible || historical)) {
@@ -8858,7 +8859,8 @@ deactivate_and_revert_new_lv:
 	}
 
 revert_new_lv:
-	lockd_lv(cmd, lv, "un", LDLV_PERSISTENT);
+	if (!lockd_lv(cmd, lv, "un", LDLV_PERSISTENT))
+		log_warn("WARNING: Failed to unlock %s.", display_lvname(lv));
 	lockd_free_lv(vg->cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args);
 
 	/* FIXME Better to revert to backup of metadata? */


