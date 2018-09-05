From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 5 Sep 2018 08:40:30 -0400
Subject: 2018-06-01-stable - dmeventd: lvm2 plugin uses envvar registry
Message-ID: <201809051240.w85CeUds006976@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8d59404f7713ae4f9a3b172dd560ed1364d8bee
Commit:        a8d59404f7713ae4f9a3b172dd560ed1364d8bee
Parent:        a1a89a453f21e7359cea14dcf86920c1e3867ec3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 27 10:18:26 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 5 14:39:14 2018 +0200

dmeventd: lvm2 plugin uses envvar registry

Thin plugin started to use configuble setting to allow to configure
usage of external scripts - however to read this value it needed to
execute internal command as dmeventd itself has no access to lvm.conf
and the API for dmeventd plugin has been kept stable.

The call of command itself was not normally 'a big issue' until users
started to use higher number of monitored LVs and execution of command
got stuck because other monitored resource already started to execute
some other lvm2 command and become blocked waiting on VG lock.

This scenario revealed necesity to somehow avoid calling lvm2 command
during resource registration - but this requires bigger changes - so
meanwhile this patch tries to minimize the possibility to hit this race
by obtaining any configurable setting just once - such patch is small
and covers majority of problem - yet better solution needs to be
introduced likely with bigger rework of dmeventd.

TODO: Avoid blocking registration of resource with execution of lvm2
commands since those can get stuck waiting on mutexes.
---
 WHATS_NEW_DM                                 |    1 +
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |   49 ++++++++++++++++++++------
 2 files changed, 39 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 72e945d..91bbc57 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.151 - 
 ==============================
+  Add hot fix to avoiding locking collision when monitoring thin-pools.
 
 Version 1.02.150 - 01 August 2018
 =================================
diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 930f9fc..5be11f1 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -31,6 +31,13 @@ static pthread_mutex_t _register_mutex = PTHREAD_MUTEX_INITIALIZER;
 static int _register_count = 0;
 static struct dm_pool *_mem_pool = NULL;
 static void *_lvm_handle = NULL;
+static DM_LIST_INIT(_env_registry);
+
+struct env_data {
+	struct dm_list list;
+	const char *cmd;
+	const char *data;
+};
 
 DM_EVENT_LOG_FN("#lvm")
 
@@ -100,6 +107,7 @@ void dmeventd_lvm2_exit(void)
 		lvm2_run(_lvm_handle, "_memlock_dec");
 		dm_pool_destroy(_mem_pool);
 		_mem_pool = NULL;
+		dm_list_init(&_env_registry);
 		lvm2_exit(_lvm_handle);
 		_lvm_handle = NULL;
 		log_debug("lvm plugin exited.");
@@ -124,6 +132,8 @@ int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
 	static char _internal_prefix[] =  "_dmeventd_";
 	char *vg = NULL, *lv = NULL, *layer;
 	int r;
+	struct env_data *env_data;
+	const char *env = NULL;
 
 	if (!dm_split_lvm_name(mem, device, &vg, &lv, &layer)) {
 		log_error("Unable to determine VG name from %s.",
@@ -137,18 +147,35 @@ int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
 		*layer = '\0';
 
 	if (!strncmp(cmd, _internal_prefix, sizeof(_internal_prefix) - 1)) {
-		dmeventd_lvm2_lock();
-		/* output of internal command passed via env var */
-		if (!dmeventd_lvm2_run(cmd))
-			cmd = NULL;
-		else if ((cmd = getenv(cmd)))
-			cmd = dm_pool_strdup(mem, cmd); /* copy with lock */
-		dmeventd_lvm2_unlock();
-
-		if (!cmd) {
-			log_error("Unable to find configured command.");
-			return 0;
+		/* check if ENVVAR wasn't already resolved */
+		dm_list_iterate_items(env_data, &_env_registry)
+			if (!strcmp(cmd, env_data->cmd)) {
+				env = env_data->data;
+				break;
+			}
+
+		if (!env) {
+			/* run lvm2 command to find out setting value */
+			dmeventd_lvm2_lock();
+			if (!dmeventd_lvm2_run(cmd) ||
+			    !(env = getenv(cmd))) {
+				log_error("Unable to find configured command.");
+				return 0;
+			}
+			/* output of internal command passed via env var */
+			env = dm_pool_strdup(_mem_pool, env); /* copy with lock */
+			dmeventd_lvm2_unlock();
+			if (!env ||
+			    !(env_data = dm_pool_zalloc(_mem_pool, sizeof(*env_data))) ||
+			    !(env_data->cmd = dm_pool_strdup(_mem_pool, cmd))) {
+				log_error("Unable to allocate env memory.");
+				return 0;
+			}
+			env_data->data = env;
+			/* add to ENVVAR registry */
+			dm_list_add(&_env_registry, &env_data->list);
 		}
+		cmd = env;
 	}
 
 	r = dm_snprintf(buffer, size, "%s %s/%s", cmd, vg, lv);


