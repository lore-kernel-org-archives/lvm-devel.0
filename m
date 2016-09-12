From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 Sep 2016 14:52:46 +0000 (UTC)
Subject: master - activation: dso always defined for monitoring query
Message-ID: <20160912145246.952EA60F35@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b592ea5bbcc9d348fdbacec1b4eeb9dded36d4ab
Commit:        b592ea5bbcc9d348fdbacec1b4eeb9dded36d4ab
Parent:        06c7220f7805d622d72968fc95c3b2bb46cde877
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 12 16:37:31 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 12 16:49:49 2016 +0200

activation: dso always defined for monitoring query

Ensure 'dso' has always a defined (NULL) value,
and also ensure NULL 'dso' is not dereferenced.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8d5a030..ba394a4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Fix possible NULL pointer derefence when checking for monitoring.
   Add lvmreport(7) man page.
   Don't install lvmraid(7) man page when raid excluded. (2.02.165)
   Report 0% as dirty (copy%) for cache without any used block.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 9977291..69d40a0 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1707,7 +1707,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 	uint32_t s;
 	static const struct lv_activate_opts zlaopts = { 0 };
 	struct lvinfo info;
-	const char *dso;
+	const char *dso = NULL;
 	int new_unmonitor;
 
 	if (!laopts)
@@ -1855,7 +1855,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		} else {
 			if (!monitored)
 				log_verbose("%s already not monitored.", display_lvname(lv));
-			else if (*dso) {
+			else if (dso && *dso) {
 				/*
 				 * Divert unmonitor away from code that depends on the new segment
 				 * type instead of the existing one if it's changing.


