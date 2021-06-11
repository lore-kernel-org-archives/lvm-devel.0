From: David Teigland <teigland@redhat.com>
Date: Fri, 11 Jun 2021 16:50:52 -0500
Subject: [QUESTION] lvmcache_label_scan: checksum error at offset xxx
In-Reply-To: <22d55c34-1b3f-16ec-b30b-8346a5c1646a@huawei.com>
References: <1cefcef9-7a6b-4054-68a6-bc0d7556065d@huawei.com>
	<ecc2153b-e722-a93a-ec15-06e35196397c@redhat.com>
	<897da3d9-6818-05c0-7d77-ec35f7a635b7@huawei.com>
	<20210610184415.GA617@redhat.com>
	<22d55c34-1b3f-16ec-b30b-8346a5c1646a@huawei.com>
Message-ID: <20210611215052.GA3709@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jun 11, 2021 at 09:53:27AM +0800, Wu Guanghao wrote:
> A high probability is caused by lock-free scanning, because after the command execution fails,
> it is normal to execute it manually again. The specific test script is already in
> https://bugzilla.redhat.com/show_bug.cgi?id=1970719

Thanks, I didn't yet see the script produce the errors, but I'll continue
trying.

I've attached an experimental patch that might help your test avoid the
errors.  The patch is an optimization that I had planned to try, but it
may also help in this case, since it acquires the vg lock prior to the
label scan.  If our understanding of the problem is correct, then this
patch would not solve all cases, but it should avoid many, like your test.
Other changes would be needed to handle remaining cases.  I'd be
interested to know if it helps.

For now, the optimization depends on the VG name being found in the first
positional command arg.  So, you'll need to use traditional command form
in which the VG name is placed at the end, e.g.

  lvcreate --type thin -V1M --thinpool poolname -n lvname vgname

Dave
-------------- next part --------------
>From 24e72200b5abc72df51e864a2adaf21a855b4b38 Mon Sep 17 00:00:00 2001
From: David Teigland <teigland@redhat.com>
Date: Fri, 11 Jun 2021 16:30:05 -0500
Subject: [PATCH] locking: hint-based vg locking optimization

This adds an optimization for some common cases in which
the VG lock can be acquired early, prior to label scan.
This reduces the chance that devices may be changed
between label scan and the normal vg lock in vg_read.

This is a proof-of-concept / experimental patch for testing.
---
 lib/commands/toolcontext.h |  1 +
 lib/label/hints.c          |  6 ++++--
 lib/label/hints.h          |  2 +-
 lib/label/label.c          | 48 ++++++++++++++++++++++++++++++++++++++--------
 lib/locking/locking.c      |  5 +++++
 5 files changed, 51 insertions(+), 11 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index a47b7d760317..8389553e7bdb 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -256,6 +256,7 @@ struct cmd_context {
 	unsigned rand_seed;
 	struct dm_list pending_delete;		/* list of LVs for removal */
 	struct dm_pool *pending_delete_mem;	/* memory pool for pending deletes */
+	int early_lock_vg_mode;
 };
 
 /*
diff --git a/lib/label/hints.c b/lib/label/hints.c
index 47236a15a63d..5546c168cf06 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -1288,12 +1288,14 @@ check:
  */
 
 int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
-	      struct dm_list *devs_in, struct dm_list *devs_out)
+	      struct dm_list *devs_in, struct dm_list *devs_out, char **vgname_out)
 {
 	struct dm_list hints_list;
 	int needs_refresh = 0;
 	char *vgname = NULL;
 
+	*vgname_out = NULL;
+
 	dm_list_init(&hints_list);
 
 	/* Decide below if the caller should create new hints. */
@@ -1433,7 +1435,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 
 	dm_list_splice(hints_out, &hints_list);
 
-	free(vgname);
+	*vgname_out = vgname;
 
 	return 1;
 }
diff --git a/lib/label/hints.h b/lib/label/hints.h
index e8cfd6a7e935..b8be4fd85683 100644
--- a/lib/label/hints.h
+++ b/lib/label/hints.h
@@ -33,7 +33,7 @@ void clear_hint_file(struct cmd_context *cmd);
 void invalidate_hints(struct cmd_context *cmd);
 
 int get_hints(struct cmd_context *cmd, struct dm_list *hints, int *newhints,
-              struct dm_list *devs_in, struct dm_list *devs_out);
+              struct dm_list *devs_in, struct dm_list *devs_out, char **vgname_out);
 
 int validate_hints(struct cmd_context *cmd, struct dm_list *hints);
 
diff --git a/lib/label/label.c b/lib/label/label.c
index cfb9ebc80b35..3ea4bfc5241e 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1032,6 +1032,7 @@ int label_scan(struct cmd_context *cmd)
 	struct dev_iter *iter;
 	struct device_list *devl, *devl2;
 	struct device *dev;
+	char *vgname_hint = NULL;
 	uint64_t max_metadata_size_bytes;
 	int device_ids_invalid = 0;
 	int using_hints;
@@ -1137,21 +1138,52 @@ int label_scan(struct cmd_context *cmd)
 	 * by using hints which tell us which devices are PVs, which
 	 * are the only devices we actually need to scan.  Without
 	 * hints we need to scan all devs to find which are PVs.
-	 *
-	 * TODO: if the command is using hints and a single vgname
+	 */
+	if (!get_hints(cmd, &hints_list, &create_hints, &all_devs, &scan_devs, &vgname_hint)) {
+		dm_list_splice(&scan_devs, &all_devs);
+		dm_list_init(&hints_list);
+		using_hints = 0;
+	} else
+		using_hints = 1;
+
+	/*
+	 * If the command is using hints and a single vgname
 	 * arg, we can also take the vg lock here, prior to scanning.
 	 * This means we would not need to rescan the PVs in the VG
 	 * in vg_read (skip lvmcache_label_rescan_vg) after the
 	 * vg lock is usually taken.  (Some commands are already
 	 * able to avoid rescan in vg_read, but locking early would
 	 * apply to more cases.)
+	 *
+	 * TODO: we don't know exactly which vg lock mode (read or write)
+	 * the command will use in vg_read() for the normal lock_vol(),
+	 * but we could make a fairly accurate guess of READ/WRITE based
+	 * on looking at the command name.  If we guess wrong we can
+	 * just unlock_vg and lock_vol again with the correct mode in
+	 * vg_read().
 	 */
-	if (!get_hints(cmd, &hints_list, &create_hints, &all_devs, &scan_devs)) {
-		dm_list_splice(&scan_devs, &all_devs);
-		dm_list_init(&hints_list);
-		using_hints = 0;
-	} else
-		using_hints = 1;
+	if (vgname_hint) {
+		uint32_t lck_type = LCK_VG_WRITE;
+
+		log_debug("Early lock vg");
+
+		/* FIXME: borrowing this lockd flag which should be
+		   quite close to what we want, based on the command name.
+		   Need to do proper mode selection here, and then check
+		   in case the later lock_vol in vg_read wants different. */
+		if (cmd->lockd_vg_default_sh)
+			lck_type = LCK_VG_READ;
+
+		if (!lock_vol(cmd, vgname_hint, lck_type, NULL)) {
+			log_warn("Could not pre-lock VG %s.", vgname_hint);
+			/* not an error since this is just an optimization */
+		} else {
+			/* Save some state indicating that the vg lock
+			   is already held so that the normal lock_vol()
+			   will know. */
+			cmd->early_lock_vg_mode = lck_type;
+		}
+	}
 
 	/*
 	 * If the total number of devices exceeds the soft open file
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index c69f08c09271..0aceb194a884 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -203,6 +203,11 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 	if (is_orphan_vg(vol))
 		return 1;
 
+	if (!is_global && cmd->early_lock_vg_mode && (lck_type != LCK_UNLOCK)) {
+		log_debug("VG was locked early.");
+		return 1;
+	}
+
 	if (!_blocking_supported)
 		flags |= LCK_NONBLOCK;
 
-- 
2.10.1

