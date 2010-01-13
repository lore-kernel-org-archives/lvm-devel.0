From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:35:54 +0100
Subject: [PATCH 3/6] Cleanup compiler warning with passing NULL to execvp
In-Reply-To: <cover.1263389392.git.zkabelac@redhat.com>
References: <cover.1263389392.git.zkabelac@redhat.com>
Message-ID: <855ac0b71271c2ce62d85a3f43e97975d20ad45f.1263389392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Cleanup gcc warning: null argument where non-null required (arg.2)
As the const declaration of execvp is a bit weird, using local
dmeventdpath string.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/libdevmapper-event.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 20d925e..4dfdf69 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -398,6 +398,8 @@ static int _start_daemon(struct dm_event_fifos *fifos)
 	int pid, ret = 0;
 	int status;
 	struct stat statbuf;
+	char dmeventdpath[] = DMEVENTD_PATH; /* const type for execvp */
+	char * const args[] = { dmeventdpath, NULL };
 
 	if (stat(fifos->client_path, &statbuf))
 		goto start_server;
@@ -437,7 +439,7 @@ static int _start_daemon(struct dm_event_fifos *fifos)
 		log_error("Unable to fork.");
 
 	else if (!pid) {
-		execvp(DMEVENTD_PATH, NULL);
+		execvp(args[0], args);
 		_exit(EXIT_FAILURE);
 	} else {
 		if (waitpid(pid, &status, 0) < 0)
-- 
1.6.6


