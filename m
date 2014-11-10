From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:10 +0000 (UTC)
Subject: master - dmeventd: time scaling for status retry
Message-ID: <20141110210610.D636860E17@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0dc73f7dbd49308b1864444d1decfaf8e10d2d81
Commit:        0dc73f7dbd49308b1864444d1decfaf8e10d2d81
Parent:        62c7027a7c675dfef8f772b1e20ac18705b847a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 8 01:29:01 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:48 2014 +0100

dmeventd: time scaling for status retry

In normal case it's too slow to wait 1 second for default.
So rather start with short time and increase sleep between status
retesting.
---
 lib/activate/activate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ac6330f..7adb90f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1649,7 +1649,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 
 		/* Check [un]monitor results */
 		/* Try a couple times if pending, but not forever... */
-		for (i = 0; i < 10; i++) {
+		for (i = 0; i < 40; i++) {
 			pending = 0;
 			monitored = seg->segtype->ops->target_monitored(seg, &pending);
 			if (pending ||
@@ -1659,7 +1659,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 						 lv->vg->name, lv->name, monitor ? "" : "un");
 			else
 				break;
-			sleep(1);
+			usleep(10000 * i);
 		}
 
 		if (r)


