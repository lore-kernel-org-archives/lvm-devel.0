From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 06:19:12 -0400
Subject: master - tidy: drop unneeded return
Message-ID: <201707201019.v6KAJCuL016529@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1fd8785ff30261d25cce2f98a8e5c566d34d3151
Commit:        1fd8785ff30261d25cce2f98a8e5c566d34d3151
Parent:        4ef6cfc882fd89ee23a12be11d631b691f7e8ddf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 19 23:53:16 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 11:20:22 2017 +0200

tidy: drop unneeded return

---
 daemons/clvmd/clvmd-openais.c |    2 --
 daemons/clvmd/clvmd.c         |    2 --
 lib/cache/lvmcache.c          |    2 --
 tools/command.c               |    2 --
 4 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/daemons/clvmd/clvmd-openais.c b/daemons/clvmd/clvmd-openais.c
index 2f1a4fd..6e09bf6 100644
--- a/daemons/clvmd/clvmd-openais.c
+++ b/daemons/clvmd/clvmd-openais.c
@@ -425,8 +425,6 @@ static void _add_up_node(const char *csid)
 	DEBUGLOG("openais_add_up_node %d\n", ninfo->nodeid);
 
 	ninfo->state = NODE_CLVMD;
-
-	return;
 }
 
 /* Call a callback for each node, so the caller knows whether it's up or down */
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 7506dca..79aa939 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -2311,13 +2311,11 @@ static void ntoh_clvm(struct clvm_header *hdr)
 static void sigusr2_handler(int sig)
 {
 	DEBUGLOG("SIGUSR2 received\n");
-	return;
 }
 
 static void sigterm_handler(int sig)
 {
 	quit = 1;
-	return;
 }
 
 static void sighup_handler(int sig)
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 8431ca1..c51e157 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1600,8 +1600,6 @@ void lvmcache_del(struct lvmcache_info *info)
 	info->label->labeller->ops->destroy_label(info->label->labeller,
 						  info->label);
 	dm_free(info);
-
-	return;
 }
 
 /*
diff --git a/tools/command.c b/tools/command.c
index bd3c7cc..a37d64d 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1965,10 +1965,8 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		_print_usage_description(cmd);
 
 	printf("\n");
-	return;
 }
 
-
 void print_usage_common_lvm(struct command_name *cname, struct command *cmd)
 {
 	int oo, opt_enum;


