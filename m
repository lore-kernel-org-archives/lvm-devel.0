From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:20 +0000 (UTC)
Subject: master - dmeventd_thin: drop umounting on error path
Message-ID: <20170120230420.477A060DB0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b95551ade0af5c1ef93f044c4508134f359e242
Commit:        8b95551ade0af5c1ef93f044c4508134f359e242
Parent:        43e3268adacbb3cd7b173e24c3423cf9d6807526
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 20 23:06:45 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:58:56 2017 +0100

dmeventd_thin: drop umounting on error path

Default internal logic will stop trying to do any 'rescue' action
when executed command fails.
This will be now fully in hands of external script if such
behaviour is needed.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |  259 +------------------------
 1 files changed, 2 insertions(+), 257 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index e1b1f77..bd70e78 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -67,246 +67,6 @@ DM_EVENT_LOG_FN("thin")
 
 #define UUID_PREFIX "LVM-"
 
-/* Figure out device UUID has LVM- prefix and is OPEN */
-static int _has_unmountable_prefix(int major, int minor)
-{
-	struct dm_task *dmt;
-	struct dm_info info;
-	const char *uuid;
-	int r = 0;
-
-	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
-		return_0;
-
-	if (!dm_task_set_major_minor(dmt, major, minor, 1))
-		goto_out;
-
-	if (!dm_task_no_flush(dmt))
-		stack;
-
-	if (!dm_task_run(dmt))
-		goto out;
-
-	if (!dm_task_get_info(dmt, &info))
-		goto out;
-
-	if (!info.exists || !info.open_count)
-		goto out; /* Not open -> not mounted */
-
-	if (!(uuid = dm_task_get_uuid(dmt)))
-		goto out;
-
-	/* Check it's public mountable LV
-	 * has prefix  LVM-  and UUID size is 68 chars */
-	if (memcmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1) ||
-	    strlen(uuid) != 68)
-		goto out;
-
-#if THIN_DEBUG
-	log_debug("Found logical volume %s (%u:%u).", uuid, major, minor);
-#endif
-	r = 1;
-out:
-	dm_task_destroy(dmt);
-
-	return r;
-}
-
-/* Get dependencies for device, and try to find matching device */
-static int _has_deps(const char *name, int tp_major, int tp_minor, int *dev_minor)
-{
-	struct dm_task *dmt;
-	const struct dm_deps *deps;
-	struct dm_info info;
-	int major, minor;
-	int r = 0;
-
-	if (!(dmt = dm_task_create(DM_DEVICE_DEPS)))
-		return 0;
-
-	if (!dm_task_set_name(dmt, name))
-		goto out;
-
-	if (!dm_task_no_open_count(dmt))
-		goto out;
-
-	if (!dm_task_run(dmt))
-		goto out;
-
-	if (!dm_task_get_info(dmt, &info))
-		goto out;
-
-	if (!(deps = dm_task_get_deps(dmt)))
-		goto out;
-
-	if (!info.exists || deps->count != 1)
-		goto out;
-
-	major = (int) MAJOR(deps->device[0]);
-	minor = (int) MINOR(deps->device[0]);
-	if ((major != tp_major) || (minor != tp_minor))
-		goto out;
-
-	*dev_minor = info.minor;
-
-	if (!_has_unmountable_prefix(major, info.minor))
-		goto out;
-
-#if THIN_DEBUG
-	{
-		char dev_name[PATH_MAX];
-		if (dm_device_get_name(major, minor, 0, dev_name, sizeof(dev_name)))
-			log_debug("Found %s (%u:%u) depends on %s.",
-				  name, major, *dev_minor, dev_name);
-	}
-#endif
-	r = 1;
-out:
-	dm_task_destroy(dmt);
-
-	return r;
-}
-
-/* Get all active devices */
-static int _find_all_devs(dm_bitset_t bs, int tp_major, int tp_minor)
-{
-	struct dm_task *dmt;
-	struct dm_names *names;
-	unsigned next = 0;
-	int minor, r = 1;
-
-	if (!(dmt = dm_task_create(DM_DEVICE_LIST)))
-		return 0;
-
-	if (!dm_task_run(dmt)) {
-		r = 0;
-		goto out;
-	}
-
-	if (!(names = dm_task_get_names(dmt))) {
-		r = 0;
-		goto out;
-	}
-
-	if (!names->dev)
-		goto out;
-
-	do {
-		names = (struct dm_names *)((char *) names + next);
-		if (_has_deps(names->name, tp_major, tp_minor, &minor))
-			dm_bit_set(bs, minor);
-		next = names->next;
-	} while (next);
-
-out:
-	dm_task_destroy(dmt);
-
-	return r;
-}
-
-static int _run(const char *cmd, ...)
-{
-	va_list ap;
-	int argc = 1; /* for argv[0], i.e. cmd */
-	int i = 0;
-	const char **argv;
-	pid_t pid = fork();
-	int status;
-
-	if (pid == 0) { /* child */
-		va_start(ap, cmd);
-		while (va_arg(ap, const char *))
-			++argc;
-		va_end(ap);
-
-		/* + 1 for the terminating NULL */
-		argv = alloca(sizeof(const char *) * (argc + 1));
-
-		argv[0] = cmd;
-		va_start(ap, cmd);
-		while ((argv[++i] = va_arg(ap, const char *)));
-		va_end(ap);
-
-		execvp(cmd, (char **)argv);
-		log_sys_error("exec", cmd);
-		exit(127);
-	}
-
-	if (pid > 0) { /* parent */
-		if (waitpid(pid, &status, 0) != pid)
-			return 0; /* waitpid failed */
-		if (!WIFEXITED(status) || WEXITSTATUS(status))
-			return 0; /* the child failed */
-	}
-
-	if (pid < 0)
-		return 0; /* fork failed */
-
-	return 1; /* all good */
-}
-
-struct mountinfo_s {
-	const char *device;
-	struct dm_info info;
-	dm_bitset_t minors; /* Bitset for active thin pool minors */
-};
-
-static int _umount_device(char *buffer, unsigned major, unsigned minor,
-			  char *target, void *cb_data)
-{
-	struct mountinfo_s *data = cb_data;
-	char *words[10];
-
-	if ((major == data->info.major) && dm_bit(data->minors, minor)) {
-		if (dm_split_words(buffer, DM_ARRAY_SIZE(words), 0, words) < DM_ARRAY_SIZE(words))
-			words[9] = NULL; /* just don't show device name */
-		log_info("Unmounting thin %s (%d:%d) of thin pool %s (%u:%u) from mount point \"%s\".",
-			 words[9] ? : "", major, minor, data->device,
-			 data->info.major, data->info.minor,
-			 target);
-		if (!_run(UMOUNT_COMMAND, "-fl", target, NULL))
-			log_error("Failed to lazy umount thin %s (%d:%d) from %s: %s.",
-				  words[9], major, minor, target, strerror(errno));
-	}
-
-	return 1;
-}
-
-/*
- * Find all thin pool LV users and try to umount them.
- * TODO: work with read-only thin pool support
- */
-static void _umount(struct dm_task *dmt)
-{
-	/* TODO: Convert to use hash to reduce memory usage */
-	static const size_t MINORS = (1U << 20); /* 20 bit */
-	struct mountinfo_s data = { NULL };
-
-	if (!dm_task_get_info(dmt, &data.info))
-		return;
-
-	data.device = dm_task_get_name(dmt);
-
-	if (!(data.minors = dm_bitset_create(NULL, MINORS))) {
-		log_error("Failed to allocate bitset. Not unmounting %s.", data.device);
-		goto out;
-	}
-
-	if (!_find_all_devs(data.minors, data.info.major, data.info.minor)) {
-		log_error("Failed to detect mounted volumes for %s.", data.device);
-		goto out;
-	}
-
-	if (!dm_mountinfo_read(_umount_device, &data)) {
-		log_error("Could not parse mountinfo file.");
-		goto out;
-	}
-
-out:
-	if (data.minors)
-		dm_bitset_destroy(data.minors);
-}
-
 static int _run_command(struct dso_state *state)
 {
 	char val[2][36];
@@ -407,7 +167,6 @@ void process_event(struct dm_task *dmt,
 	char *target_type = NULL;
 	char *params;
 	int needs_policy = 0;
-	int needs_umount = 0;
 	struct dm_task *new_dmt = NULL;
 
 #if THIN_DEBUG
@@ -461,7 +220,6 @@ void process_event(struct dm_task *dmt,
 
 	if (!dm_get_status_thin_pool(state->mem, params, &tps)) {
 		log_error("Failed to parse status.");
-		needs_umount = 1;
 		goto out;
 	}
 
@@ -499,9 +257,6 @@ void process_event(struct dm_task *dmt,
 		state->metadata_percent_check = (state->metadata_percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
 
 		needs_policy = 1;
-
-		if (state->metadata_percent >= UMOUNT_THRESH)
-			needs_umount = 1;
 	}
 
 	state->data_percent = dm_make_percent(tps->used_data_blocks, tps->total_data_blocks);
@@ -518,9 +273,6 @@ void process_event(struct dm_task *dmt,
 		state->data_percent_check = (state->data_percent / CHECK_STEP) * CHECK_STEP + CHECK_STEP;
 
 		needs_policy = 1;
-
-		if (state->data_percent >= UMOUNT_THRESH)
-			needs_umount = 1;
 	}
 
 	/* Reduce number of _use_policy() calls by power-of-2 factor till frequency of MAX_FAILS is reached.
@@ -539,16 +291,9 @@ void process_event(struct dm_task *dmt,
 	} else
 		state->max_fails = 1; /* Reset on success */
 
-	if (needs_policy &&
-	    _use_policy(dmt, state))
-		needs_umount = 0; /* No umount when command was successful */
+	if (needs_policy)
+		_use_policy(dmt, state);
 out:
-	if (needs_umount) {
-		_umount(dmt);
-		/* Until something changes, do not retry any more actions */
-		state->data_percent_check = state->metadata_percent_check = (DM_PERCENT_1 * 101);
-	}
-
 	if (tps)
 		dm_pool_free(state->mem, tps);
 


