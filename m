From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 11:31:32 +0000 (UTC)
Subject: master - libdm: enclose dm_stats_walk_do/while() body in do..while
Message-ID: <20160708113132.40F1360EE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e06b33c51e2b264ad8a48b61f18bf3bff37c992
Commit:        5e06b33c51e2b264ad8a48b61f18bf3bff37c992
Parent:        6233bcf52d98d9d0a3c87b22cb7700521b5358a2
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 7 21:28:35 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 11:14:22 2016 +0100

libdm: enclose dm_stats_walk_do/while() body in do..while

The call to dm_stats_walk_start() before the do statement makes
dm_stats_walk_do() behave inconsistently depending on context;
wrap them in an additional do { } while (0) so that the macro
always expands to a valid statement.
---
 libdm/libdevmapper.h |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 415928c..ec64426 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1146,15 +1146,17 @@ for (dm_stats_walk_init((dms), DM_STATS_WALK_GROUP),		\
  * empty.
  */
 #define dm_stats_walk_do(dms)					\
-dm_stats_walk_start((dms));					\
-do
+do {								\
+	dm_stats_walk_start((dms));				\
+	do
 
 /*
  * Start a 'while' style loop or end a 'do..while' loop iterating over the
  * regions contained in dm_stats handle 'dms'.
  */
 #define dm_stats_walk_while(dms)				\
-while(!dm_stats_walk_end((dms)))
+	while(!dm_stats_walk_end((dms)));			\
+} while (0)
 
 /*
  * Cursor relative property methods


