From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:32 +0200
Subject: [PATCH 25/30] Proper C declaration
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <38ca589b12f1e7635bd07455884933002461d7a6.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/dmeventd.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index d179879..bbe6e10 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1477,7 +1477,7 @@ static void _process_request(struct dm_event_fifos *fifos)
 	dm_free(msg.data);
 }
 
-static void _process_initial_registrations()
+static void _process_initial_registrations(void)
 {
 	int i = 0;
 	char *reg;
@@ -1697,7 +1697,7 @@ static void _daemonize(void)
 	setsid();
 }
 
-static void restart()
+static void restart(void)
 {
 	struct dm_event_fifos fifos;
 	struct dm_event_daemon_message msg = { 0, 0, NULL };
-- 
1.7.3.1


