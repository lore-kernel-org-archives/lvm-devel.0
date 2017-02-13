From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 23:06:07 +0000 (UTC)
Subject: master - activation: trust 'pending' status reported by dmeventd
Message-ID: <20170213230607.E590A606FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65b82a80720b137e24077c29f9c52d6ad43f93a5
Commit:        65b82a80720b137e24077c29f9c52d6ad43f93a5
Parent:        05dd566a52e4311c0626eb1a1250042aba746fae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 13 22:50:19 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 14 00:04:26 2017 +0100

activation: trust 'pending' status reported by dmeventd

Only usleep when dmeventd reports 'pending' otherwise trust reported
state.
---
 lib/activate/activate.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 608611f..ea56735 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1948,16 +1948,13 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 
 		/* Check [un]monitor results */
 		/* Try a couple times if pending, but not forever... */
-		for (i = 0; i < 40; i++) {
+		for (i = 0;; i++) {
 			pending = 0;
 			monitored = seg->segtype->ops->target_monitored(seg, &pending);
-			if (pending ||
-			    (!monitored && monitor) ||
-			    (monitored && !monitor))
-				log_very_verbose("%s %smonitoring still pending: waiting...",
-						 display_lvname(lv), monitor ? "" : "un");
-			else
+			if (!pending || i >= 40)
 				break;
+			log_very_verbose("%s %smonitoring still pending: waiting...",
+					 display_lvname(lv), monitor ? "" : "un");
 			usleep(10000 * i);
 		}
 


