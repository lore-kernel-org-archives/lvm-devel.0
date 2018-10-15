From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:54:51 -0400
Subject: master - cov: dmeventd plugin fix memleak
Message-ID: <201810151554.w9FFsp3g020469@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3222924c3dd595f6d185b180341acfa46954307a
Commit:        3222924c3dd595f6d185b180341acfa46954307a
Parent:        fbfbbf6d6a4c27d1a9965c196cf625a49223eccd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:21:55 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:22 2018 +0200

cov: dmeventd plugin fix memleak

Fix memory leak when policy command fails too frequently and
plugin decided to skip it.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |    2 +-
 daemons/dmeventd/plugins/vdo/dmeventd_vdo.c   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 14bfd80..64fe6ca 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -286,7 +286,7 @@ void process_event(struct dm_task *dmt,
 		if (state->fails++ <= state->max_fails) {
 			log_debug("Postponing frequently failing policy (%u <= %u).",
 				  state->fails - 1, state->max_fails);
-			return;
+			goto out;
 		}
 		if (state->max_fails < MAX_FAILS)
 			state->max_fails <<= 1;
diff --git a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
index d77ca79..abed41e 100644
--- a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
+++ b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
@@ -245,7 +245,7 @@ void process_event(struct dm_task *dmt,
 		if (state->fails++ <= state->max_fails) {
 			log_debug("Postponing frequently failing policy (%u <= %u).",
 				  state->fails - 1, state->max_fails);
-			return;
+			goto out;
 		}
 		if (state->max_fails < MAX_FAILS)
 			state->max_fails <<= 1;


