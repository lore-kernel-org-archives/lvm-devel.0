From: Ferenc Wágner <wferi@niif.hu>
Date: Wed,  8 Jul 2015 14:41:22 +0200
Subject: [PATCH 1/6] cmirrord: move generic setup from daemonize() to init_all()
In-Reply-To: <1436359287-6682-1-git-send-email-wferi@niif.hu>
References: <1436359287-6682-1-git-send-email-wferi@niif.hu>
Message-ID: <1436359287-6682-2-git-send-email-wferi@niif.hu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Pidfile creation, removal and signal setup are applicable to foreground
processes as well.
---
 daemons/cmirrord/clogd.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/daemons/cmirrord/clogd.c b/daemons/cmirrord/clogd.c
index 86d06bd..b4736e1 100644
--- a/daemons/cmirrord/clogd.c
+++ b/daemons/cmirrord/clogd.c
@@ -209,6 +209,16 @@ static void daemonize(void)
 	}
 
 	LOG_OPEN("cmirrord", LOG_PID, LOG_DAEMON);
+}
+
+/*
+ * init_all
+ *
+ * Initialize modules.  Exit on failure.
+ */
+static void init_all(void)
+{
+	int r;
 
 	(void) dm_prepare_selinux_context(CMIRRORD_PIDFILE, S_IFREG);
 	if (dm_create_lockfile(CMIRRORD_PIDFILE) == 0)
@@ -227,16 +237,6 @@ static void daemonize(void)
 	signal(SIGUSR2, &sig_handler);
 	sigemptyset(&signal_mask);
 	signal_received = 0;
-}
-
-/*
- * init_all
- *
- * Initialize modules.  Exit on failure.
- */
-static void init_all(void)
-{
-	int r;
 
 	if ((r = init_local()) ||
 	    (r = init_cluster())) {
-- 
1.7.10.4


