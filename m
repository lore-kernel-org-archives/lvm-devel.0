From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 17:37:10 -0500
Subject: master - activation: also lock memory for clustered locking
Message-ID: <201712042237.vB4MbAtS005929@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=698483b5a1bc71e3f48581e2e0bbc269e7d237a9
Commit:        698483b5a1bc71e3f48581e2e0bbc269e7d237a9
Parent:        406b566cfc4be2cc04157ea7bd3c24ea729a4bb5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 18:40:37 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 23:33:02 2017 +0100

activation: also lock memory for clustered locking

Commit  c086dfadc389551b9a2d7b4c26931e5e74ada8d6 missed to lock memory
for clustering suspend part since it's using differnt locking reason.
---
 lib/mm/memlock.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 7edd9de..f72b86c 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -602,7 +602,9 @@ static void _unlock_mem_if_possible(struct cmd_context *cmd)
  */
 void critical_section_inc(struct cmd_context *cmd, const char *reason)
 {
-	if (!_critical_section && (strcmp(reason, "suspending") == 0)) {
+	if (!_critical_section &&
+	    ((strcmp(reason, "suspending") == 0) ||
+	     (strcmp(reason, "locking for suspend") == 0))) {
 		/*
 		 * Profiles are loaded on-demand so make sure that before
 		 * entering the critical section all needed profiles are


