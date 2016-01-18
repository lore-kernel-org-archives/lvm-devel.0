From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 18 Jan 2016 15:35:43 +0000 (UTC)
Subject: master - lvmlockd: cosemtic improvements to logging
Message-ID: <20160118153543.58B7A60674@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06346eab849b272bcd99196a9b594da29abdb19a
Commit:        06346eab849b272bcd99196a9b594da29abdb19a
Parent:        95ead96004c303f4285acfc223bba58e82e3ee87
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 15 15:34:49 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 18 09:35:21 2016 -0600

lvmlockd: cosemtic improvements to logging

Also pass our name to sanlock so it appears in
the sanlock status output.
---
 daemons/lvmlockd/lvmlockd-core.c     |   20 +-------------------
 daemons/lvmlockd/lvmlockd-internal.h |   17 +++++++++++++++++
 daemons/lvmlockd/lvmlockd-sanlock.c  |   17 +++++++++++------
 3 files changed, 29 insertions(+), 25 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 53fc0d5..4cd3284 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -741,24 +741,6 @@ static const char *op_str(int x)
 	};
 }
 
-static const char *mode_str(int x)
-{
-	switch (x) {
-	case LD_LK_IV:
-		return "iv";
-	case LD_LK_UN:
-		return "un";
-	case LD_LK_NL:
-		return "nl";
-	case LD_LK_SH:
-		return "sh";
-	case LD_LK_EX:
-		return "ex";
-	default:
-		return ".";
-	};
-}
-
 int last_string_from_args(char *args_in, char *last)
 {
 	const char *args = args_in;
@@ -1365,7 +1347,7 @@ static int res_convert(struct lockspace *ls, struct resource *r,
 
 	r->last_client_id = act->client_id;
 
-	log_debug("S %s R %s res_convert cl %u mode %d", ls->name, r->name, act->client_id, act->mode);
+	log_debug("S %s R %s res_convert cl %u mode %s", ls->name, r->name, act->client_id, mode_str(act->mode));
 
 	if (act->mode == LD_LK_EX && lk->mode == LD_LK_SH && r->sh_count > 1)
 		return -EAGAIN;
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 3afa75a..2e21981 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -351,6 +351,23 @@ int lockspaces_empty(void);
 int last_string_from_args(char *args_in, char *last);
 int version_from_args(char *args, unsigned int *major, unsigned int *minor, unsigned int *patch);
 
+static inline const char *mode_str(int x)
+{
+	switch (x) {
+	case LD_LK_IV:
+		return "iv";
+	case LD_LK_UN:
+		return "un";
+	case LD_LK_NL:
+		return "nl";
+	case LD_LK_SH:
+		return "sh";
+	case LD_LK_EX:
+		return "ex";
+	default:
+		return ".";
+	};
+}
 
 #ifdef LOCKDDLM_SUPPORT
 
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 6f287b9..6694652 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1324,6 +1324,7 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 	struct lm_sanlock *lms = (struct lm_sanlock *)ls->lm_data;
 	struct rd_sanlock *rds = (struct rd_sanlock *)r->lm_data;
 	struct sanlk_resource *rs;
+	struct sanlk_options opt;
 	uint64_t lock_lv_offset;
 	uint32_t flags = 0;
 	struct val_blk vb;
@@ -1397,8 +1398,8 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 
 	rs->flags |= SANLK_RES_PERSISTENT;
 
-	log_debug("S %s R %s lock_san acquire %s:%llu",
-		  ls->name, r->name, rs->disks[0].path,
+	log_debug("S %s R %s lock_san %s at %s:%llu",
+		  ls->name, r->name, mode_str(ld_mode), rs->disks[0].path,
 		  (unsigned long long)rs->disks[0].offset);
 
 	if (daemon_test) {
@@ -1424,7 +1425,10 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 	flags |= SANLK_ACQUIRE_OWNER_NOWAIT;
 #endif
 
-	rv = sanlock_acquire(lms->sock, -1, flags, 1, &rs, NULL);
+	memset(&opt, 0, sizeof(opt));
+	sprintf(opt.owner_name, "%s", "lvmlockd");
+
+	rv = sanlock_acquire(lms->sock, -1, flags, 1, &rs, &opt);
 
 	if (rv == -EAGAIN) {
 		/*
@@ -1584,7 +1588,8 @@ int lm_convert_sanlock(struct lockspace *ls, struct resource *r,
 	uint32_t flags = 0;
 	int rv;
 
-	log_debug("S %s R %s convert_san", ls->name, r->name);
+	log_debug("S %s R %s convert_san %s to %s",
+		  ls->name, r->name, mode_str(r->mode), mode_str(ld_mode));
 
 	if (daemon_test)
 		goto rs_flag;
@@ -1688,8 +1693,8 @@ int lm_unlock_sanlock(struct lockspace *ls, struct resource *r,
 	struct val_blk vb;
 	int rv;
 
-	log_debug("S %s R %s unlock_san r_version %u flags %x",
-		  ls->name, r->name, r_version, lmu_flags);
+	log_debug("S %s R %s unlock_san %s r_version %u flags %x",
+		  ls->name, r->name, mode_str(r->mode), r_version, lmu_flags);
 
 	if (daemon_test) {
 		if (rds->vb && r_version && (r->mode == LD_LK_EX)) {


