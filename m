From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 20 Apr 2016 14:07:32 +0000 (UTC)
Subject: master - lvmetad: connect from forked polling process
Message-ID: <20160420140732.798E261E55@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c104c5de9b019f5cf9b93ff2ee5468e1f0641d1
Commit:        5c104c5de9b019f5cf9b93ff2ee5468e1f0641d1
Parent:        955326067348d29aa7b42159f43b119ce7d8c491
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 19 17:07:22 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 20 09:04:39 2016 -0500

lvmetad: connect from forked polling process

With commit 5e9e43074a6c, lvmetad connections are
now made explicitly, so a new connection must be
created from a child created for polling.
---
 tools/polldaemon.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 71d6b3e..c2211d7 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -596,6 +596,11 @@ static int _poll_daemon(struct cmd_context *cmd, struct poll_operation_id *id,
 			parms->progress_display = 0; /* Child */
 		/* FIXME Use wait_event (i.e. interval = 0) and */
 		/*       fork one daemon per copy? */
+
+		if (daemon_mode == 1) {
+			if (!lvmetad_connect(cmd))
+				log_warn("WARNING: lvm polling process %d cannot connect to lvmetad.", getpid());
+		}
 	}
 
 	/*


