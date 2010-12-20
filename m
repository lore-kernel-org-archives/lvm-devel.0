From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:48:29 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20101220134829.14860.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:48:28

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Replace multiple fprintf calls with one large string parameter

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89

--- LVM2/daemons/clvmd/clvmd.c	2010/12/13 10:49:03	1.88
+++ LVM2/daemons/clvmd/clvmd.c	2010/12/20 13:48:28	1.89
@@ -143,38 +143,37 @@
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


