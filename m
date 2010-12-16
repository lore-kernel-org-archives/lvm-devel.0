From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:18 +0100
Subject: [PATCH 10/20] Simplify usage fprintf clvmd
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <faaf70a3afa3264aa8d19ac9f73cf017e61ec132.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use one fprintf for usage print.
Use const char* for prog parameter.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c |   41 ++++++++++++++++++++---------------------
 1 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 45e2486..1a35c49 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -143,38 +143,37 @@ static void add_reply_to_list(struct local_client *client, int status,
 static if_type_t parse_cluster_interface(char *ifname);
 static if_type_t get_cluster_type(void);
 
-static void usage(char *prog, FILE *file)
+static void usage(const char *prog, FILE *file)
 {
-	fprintf(file, "Usage:\n");
-	fprintf(file, "%s [Vhd]\n", prog);
-	fprintf(file, "\n");
-	fprintf(file, "   -V       Show version of clvmd\n");
-	fprintf(file, "   -h       Show this help information\n");
-	fprintf(file, "   -d       Set debug level\n");
-	fprintf(file, "            If starting clvmd then don't fork, run in the foreground\n");
-	fprintf(file, "   -R       Tell all running clvmds in the cluster to reload their device cache\n");
-	fprintf(file, "   -S       Restart clvmd, preserving exclusive locks\n");
-	fprintf(file, "   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n");
-	fprintf(file, "   -t<secs> Command timeout (default 60 seconds)\n");
-	fprintf(file, "   -T<secs> Startup timeout (default none)\n");
-	fprintf(file, "   -I<cmgr> Cluster manager (default: auto)\n");
-	fprintf(file, "            Available cluster managers: ");
+	fprintf(file, "Usage:\n"
+		"%s [Vhd]\n\n"
+		"   -V       Show version of clvmd\n"
+		"   -h       Show this help information\n"
+		"   -d       Set debug level\n"
+		"            If starting clvmd then don't fork, run in the foreground\n"
+		"   -R       Tell all running clvmds in the cluster to reload their device cache\n"
+		"   -S       Restart clvmd, preserving exclusive locks\n"
+		"   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n"
+		"   -t<secs> Command timeout (default 60 seconds)\n"
+		"   -T<secs> Startup timeout (default none)\n"
+		"   -I<cmgr> Cluster manager (default: auto)\n"
+		"            Available cluster managers: "
 #ifdef USE_COROSYNC
-	fprintf(file, "corosync ");
+		"corosync "
 #endif
 #ifdef USE_CMAN
-	fprintf(file, "cman ");
+		"cman "
 #endif
 #ifdef USE_OPENAIS
-	fprintf(file, "openais ");
+		"openais "
 #endif
 #ifdef USE_GULM
-	fprintf(file, "gulm ");
+		"gulm "
 #endif
 #ifdef USE_SINGLENODE
-	fprintf(file, "singlenode");
+		"singlenode "
 #endif
-	fprintf(file, "\n");
+		"\n", prog);
 }
 
 /* Called to signal the parent how well we got on during initialisation */
-- 
1.7.3.3


