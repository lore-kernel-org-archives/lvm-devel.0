From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 20 Aug 2015 17:07:04 +0000 (UTC)
Subject: master - cmirrord: move generic setup from daemonize() to init_all()
Message-ID: <20150820170704.1FCFC61147@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0d6056870769a1f64204532471a8f9bd398093e
Commit:        c0d6056870769a1f64204532471a8f9bd398093e
Parent:        23770214a9ac844e72e62de589a4d61cd0e125bc
Author:        Ferenc W??gner <wferi@niif.hu>
AuthorDate:    Wed Jul 8 14:41:22 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Aug 20 19:06:47 2015 +0200

cmirrord: move generic setup from daemonize() to init_all()

Apply pidfile creation, removal and signal setup to foreground processes too.
---
 daemons/cmirrord/clogd.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

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


