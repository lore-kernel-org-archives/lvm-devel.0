From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:21 +0000 (UTC)
Subject: master - dmeventd: simplify fifos init
Message-ID: <20130923101621.A537E606F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a94e28ae019b94aa48dbaf1db83cc30bfdee0f4f
Commit:        a94e28ae019b94aa48dbaf1db83cc30bfdee0f4f
Parent:        b33b618fc8e83a033d91814facd0312c84597372
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 5 13:14:19 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 11:35:15 2013 +0200

dmeventd: simplify fifos init

Simplier code.
---
 daemons/dmeventd/dmeventd.c |   22 ++++++----------------
 1 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 9c7a6c6..3754714 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1247,16 +1247,6 @@ static int _get_timeout(struct message_data *message_data)
 	return thread ? 0 : -ENODEV;
 }
 
-/* Initialize a fifos structure with path names. */
-static void _init_fifos(struct dm_event_fifos *fifos)
-{
-	fifos->client = -1;
-	fifos->server = -1;
-
-	fifos->client_path = DM_EVENT_FIFO_CLIENT;
-	fifos->server_path = DM_EVENT_FIFO_SERVER;
-}
-
 /* Open fifos used for client communication. */
 static int _open_fifos(struct dm_event_fifos *fifos)
 {
@@ -1706,8 +1696,6 @@ static int _systemd_handover(struct dm_event_fifos *fifos)
 	unsigned long env_pid, env_listen_fds;
 	int r = 0;
 
-	memset(fifos, 0, sizeof(*fifos));
-
 	/* SD_ACTIVATION must be set! */
 	if (!(e = getenv(SD_ACTIVATION_ENV_VAR_NAME)) || strcmp(e, "1"))
 		goto out;
@@ -1929,7 +1917,12 @@ static void usage(char *prog, FILE *file)
 int main(int argc, char *argv[])
 {
 	signed char opt;
-	struct dm_event_fifos fifos;
+	struct dm_event_fifos fifos = {
+		.client = -1,
+		.server = -1,
+		.client_path = DM_EVENT_FIFO_CLIENT,
+		.server_path = DM_EVENT_FIFO_SERVER
+	};
 	int nothreads;
 	//struct sys_log logdata = {DAEMON_NAME, LOG_DAEMON};
 
@@ -2005,9 +1998,6 @@ int main(int argc, char *argv[])
 	//multilog_init_verbose(std_syslog, _LOG_DEBUG);
 	//multilog_async(1);
 
-	if (!_systemd_activation)
-		_init_fifos(&fifos);
-
 	pthread_mutex_init(&_global_mutex, NULL);
 
 	if (!_systemd_activation && !_open_fifos(&fifos))


