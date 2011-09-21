From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 21 Sep 2011 13:36:43 +0200
Subject: [PATCH 1/2] Clvmd fix restart
In-Reply-To: <cover.1316604772.git.zkabelac@redhat.com>
References: <cover.1316604772.git.zkabelac@redhat.com>
Message-ID: <498932ea49b0379d95cf520090fa575551360ff6.1316604772.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch fixes two reads in the iteration loop,
where only every second lock is then passed to restarted clvmd.

Also moves initialisation of  'hn' to NULL - since for the first loop
it's already initialized to NULL, while the second loop
needs to start with 'hn' == NULL.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-command.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 75f1367..c83e2cf 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -369,7 +369,6 @@ static int restart_clvmd(void)
 	DEBUGLOG("clvmd restart requested\n");
 
 	/* Count exclusively-open LVs */
-	hn = NULL;
 	do {
 		hn = get_next_excl_lock(hn, &lv_name);
 		if (lv_name)
@@ -403,6 +402,7 @@ static int restart_clvmd(void)
 	 */
 
 	/* Now add the exclusively-open LVs */
+	hn = NULL;
 	do {
 		hn = get_next_excl_lock(hn, &lv_name);
 		if (lv_name) {
@@ -414,7 +414,6 @@ static int restart_clvmd(void)
 				goto_out;
 
 			DEBUGLOG("excl lock: %s\n", lv_name);
-			hn = get_next_excl_lock(hn, &lv_name);
 		}
 	} while (hn && *lv_name);
 	argv[argc++] = NULL;
-- 
1.7.6.2


