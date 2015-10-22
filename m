From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:34:17 +0000 (UTC)
Subject: master - cleanup: indents
Message-ID: <20151022213417.3E7DE60612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a2d0a0c729e80e4cd122532829f3a11e6566823
Commit:        1a2d0a0c729e80e4cd122532829f3a11e6566823
Parent:        b1319e04020c3cb77b3a5c5a765606efa0b34b83
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 09:57:44 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:46:10 2015 +0200

cleanup: indents

---
 daemons/dmeventd/dmeventd.c                   |    8 ++++----
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |    4 ++--
 lib/metadata/lv_manip.c                       |    2 +-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 9662c0e..6f3bfff 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -230,6 +230,7 @@ struct thread_status {
 	void *dso_private; /* dso per-thread status variable */
 	/* TODO per-thread mutex */
 };
+
 static DM_LIST_INIT(_thread_registry);
 static DM_LIST_INIT(_thread_registry_unused);
 
@@ -819,6 +820,7 @@ static sigset_t _unblock_sigalrm(void)
 	sigemptyset(&set);
 	sigaddset(&set, SIGALRM);
 	pthread_sigmask(SIG_UNBLOCK, &set, &old);
+
 	return old;
 }
 
@@ -1412,7 +1414,7 @@ fail:
  * and a complete message is read.  Must not block indefinitely.
  */
 static int _client_read(struct dm_event_fifos *fifos,
-		       struct dm_event_daemon_message *msg)
+			struct dm_event_daemon_message *msg)
 {
 	struct timeval t;
 	unsigned bytes = 0;
@@ -1859,7 +1861,6 @@ static void _daemonize(void)
 	case -1:
 		log_sys_error("fork", "");
 		exit(EXIT_FAILURE);
-
 	case 0:		/* Child */
 		break;
 
@@ -2107,8 +2108,6 @@ int main(int argc, char *argv[])
 		.server_path = DM_EVENT_FIFO_SERVER
 	};
 	time_t now, idle_exit_timeout = DMEVENTD_IDLE_EXIT_TIMEOUT;
-	//struct sys_log logdata = {DAEMON_NAME, LOG_DAEMON};
-
 	opterr = 0;
 	optind = 0;
 
@@ -2195,6 +2194,7 @@ int main(int argc, char *argv[])
 	/* Signal parent, letting them know we are ready to go. */
 	if (!_foreground)
 		kill(getppid(), SIGTERM);
+
 	log_notice("dmeventd ready for processing.");
 
 	_idle_since = time(NULL);
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 2f200ba..99f2680 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -42,8 +42,8 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 			goto out; /* already reported */
 
 		log_error("Device #%d of %s array, %s, has failed.",
-			 (int)(d - status->dev_health),
-			 status->raid_type, device);
+			  (int)(d - status->dev_health),
+			  status->raid_type, device);
 
 		state->failed = 1;
 		if (!dmeventd_lvm2_run_with_lock(state->cmd_lvscan))
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 316710b..738343f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4495,7 +4495,7 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 		if (!lv_snapshot_percent(lv, &percent))
 			return_0;
 		if (!(DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) || percent <= policy_threshold)
-		return 1; /* nothing to do */
+			return 1; /* nothing to do */
 	}
 
 	lp->extents = policy_amount;


