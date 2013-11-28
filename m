From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:48:47 +0000 (UTC)
Subject: master - dmeventd: simplify error path
Message-ID: <20131128114847.0082760F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3679590dfb9839196c36ac74b86377ae2a10f8e
Commit:        b3679590dfb9839196c36ac74b86377ae2a10f8e
Parent:        6dae2373034ce3fc11f226c963d81a670043191a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 25 14:24:25 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:45:02 2013 +0100

dmeventd: simplify error path

Use common 'bad:' label for exit error path where
fifo is closed before exit().
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   21 ++++++++++++---------
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 564419f..1f1cde1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.84 -
 ====================================
+  Close fifos before exiting in dmeventd restart() error path.
   Move printf format string directly into dm_asprintf args list.
   Catch invalid use of string sort values when reporting numerical fields.
 
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 301c5f5..f2d6671 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1848,20 +1848,18 @@ static void restart(void)
 
 	if (!dm_event_get_version(&fifos, &version)) {
 		fprintf(stderr, "WARNING: Could not communicate with existing dmeventd.\n");
-		fini_fifos(&fifos);
-		exit(EXIT_FAILURE);
+		goto bad;
 	}
 
 	if (version < 1) {
 		fprintf(stderr, "WARNING: The running dmeventd instance is too old.\n"
 			        "Protocol version %d (required: 1). Action cancelled.\n",
 			        version);
-		exit(EXIT_FAILURE);
+		goto bad;
 	}
 
-	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_GET_STATUS, "-", "-", 0, 0)) {
-		exit(EXIT_FAILURE);
-	}
+	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_GET_STATUS, "-", "-", 0, 0))
+		goto bad;
 
 	message = msg.data;
 	message = strchr(message, ' ');
@@ -1876,13 +1874,13 @@ static void restart(void)
 
 	if (!(_initial_registrations = dm_malloc(sizeof(char*) * (count + 1)))) {
 		fprintf(stderr, "Memory allocation registration failed.\n");
-		exit(EXIT_FAILURE);
+		goto bad;
 	}
 
 	for (i = 0; i < count; ++i) {
 		if (!(_initial_registrations[i] = dm_strdup(message))) {
 			fprintf(stderr, "Memory allocation for message failed.\n");
-			exit(EXIT_FAILURE);
+			goto bad;
 		}
 		message += strlen(message) + 1;
 	}
@@ -1890,7 +1888,7 @@ static void restart(void)
 
 	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_DIE, "-", "-", 0, 0)) {
 		fprintf(stderr, "Old dmeventd refused to die.\n");
-		exit(EXIT_FAILURE);
+		goto bad;
 	}
 
 	/*
@@ -1904,6 +1902,11 @@ static void restart(void)
 	}
 
 	fini_fifos(&fifos);
+
+	return;
+bad:
+	fini_fifos(&fifos);
+	exit(EXIT_FAILURE);
 }
 
 static void usage(char *prog, FILE *file)


