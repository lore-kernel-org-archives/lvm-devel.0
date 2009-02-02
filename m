From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 2 Feb 2009 14:34:26 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/Makefile.in dae ...
Message-ID: <20090202143426.5539.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-02-02 14:34:25

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : Makefile.in clvmd-corosync.c clvmd-openais.c 
	                 clvmd.c 

Log message:
	Allow clvmd to be built with all cluster managers & select one on cmdline.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1031&r2=1.1032
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2009/01/29 15:23:15	1.1031
+++ LVM2/WHATS_NEW	2009/02/02 14:34:24	1.1032
@@ -1,6 +1,7 @@
 Version 2.02.45 - 
 ===================================
-  Mention --with-clvmd=corosync in ./configure
+  Allow clvmd to be built with all cluster managers & select one on cmdline.
+  Mention --with-clvmd=corosync in ./configure.
   Replace internal vg_check_status() implementation.
   Rename vg_read() to vg_read_internal().
 
--- LVM2/daemons/clvmd/Makefile.in	2009/01/22 10:21:12	1.25
+++ LVM2/daemons/clvmd/Makefile.in	2009/02/02 14:34:25	1.26
@@ -21,31 +21,26 @@
 	lvm-functions.c  \
 	refresh_clvmd.c
 
-ifeq ("@CLVMD@", "gulm")
+ifneq (,$(findstring gulm,, "@CLVMD@,"))
 	GULM = yes
 endif
 
-ifeq ("@CLVMD@", "cman")
+ifneq (,$(findstring cman,, "@CLVMD@,"))
 	CMAN = yes
 endif
 
-ifeq ("@CLVMD@", "openais")
+ifneq (,$(findstring openais,, "@CLVMD@,"))
 	OPENAIS = yes
-	GULM = no
-	CMAN = no
 endif
 
-ifeq ("@CLVMD@", "all")
-	GULM = yes
-	CMAN = yes
-	OPENAIS = no
-	COROSYNC = no
+ifneq (,$(findstring corosync,, "@CLVMD@,"))
+	COROSYNC = yes
 endif
 
-ifeq ("@CLVMD@", "corosync")
-	GULM = no
-	CMAN = no
-	OPENAIS = no
+ifneq (,$(findstring all,, "@CLVMD@,"))
+	GULM = yes
+	CMAN = yes
+	OPENAIS = yes
 	COROSYNC = yes
 endif
 
--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/01/22 10:21:12	1.1
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2009/02/02 14:34:25	1.2
@@ -194,7 +194,7 @@
 	return -1;
 }
 
-static char *print_csid(const char *csid)
+static char *print_corosync_csid(const char *csid)
 {
 	static char buf[128];
 	int id;
@@ -392,7 +392,7 @@
 	ninfo = dm_hash_lookup_binary(node_hash, csid, COROSYNC_CSID_LEN);
 	if (!ninfo)
 	{
-		sprintf(name, "UNKNOWN %s", print_csid(csid));
+		sprintf(name, "UNKNOWN %s", print_corosync_csid(csid));
 		return -1;
 	}
 
@@ -414,7 +414,7 @@
 	ninfo = dm_hash_lookup_binary(node_hash, csid, COROSYNC_CSID_LEN);
 	if (!ninfo) {
 		DEBUGLOG("corosync_add_up_node no node_hash entry for csid %s\n",
-			 print_csid(csid));
+			 print_corosync_csid(csid));
 		return;
 	}
 
--- LVM2/daemons/clvmd/clvmd-openais.c	2008/11/04 16:41:47	1.9
+++ LVM2/daemons/clvmd/clvmd-openais.c	2009/02/02 14:34:25	1.10
@@ -195,7 +195,7 @@
 	return -1;
 }
 
-static char *print_csid(const char *csid)
+static char *print_openais_csid(const char *csid)
 {
 	static char buf[128];
 	int id;
@@ -415,7 +415,7 @@
 	ninfo = dm_hash_lookup_binary(node_hash, csid, OPENAIS_CSID_LEN);
 	if (!ninfo)
 	{
-		sprintf(name, "UNKNOWN %s", print_csid(csid));
+		sprintf(name, "UNKNOWN %s", print_openais_csid(csid));
 		return -1;
 	}
 
@@ -437,7 +437,7 @@
 	ninfo = dm_hash_lookup_binary(node_hash, csid, OPENAIS_CSID_LEN);
 	if (!ninfo) {
 		DEBUGLOG("openais_add_up_node no node_hash entry for csid %s\n",
-			 print_csid(csid));
+			 print_openais_csid(csid));
 		return;
 	}
 
--- LVM2/daemons/clvmd/clvmd.c	2009/01/22 10:21:12	1.53
+++ LVM2/daemons/clvmd/clvmd.c	2009/02/02 14:34:25	1.54
@@ -108,6 +108,8 @@
 #define DFAIL_TIMEOUT    5
 #define SUCCESS          0
 
+typedef enum {IF_AUTO, IF_CMAN, IF_GULM, IF_OPENAIS, IF_COROSYNC} if_type_t;
+
 /* Prototypes for code further down */
 static void sigusr2_handler(int sig);
 static void sighup_handler(int sig);
@@ -144,6 +146,7 @@
 static void ntoh_clvm(struct clvm_header *hdr);
 static void add_reply_to_list(struct local_client *client, int status,
 			      const char *csid, const char *buf, int len);
+static if_type_t parse_cluster_interface(char *ifname);
 
 static void usage(char *prog, FILE *file)
 {
@@ -158,6 +161,20 @@
 	fprintf(file, "   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n");
 	fprintf(file, "   -t<secs> Command timeout (default 60 seconds)\n");
 	fprintf(file, "   -T<secs> Startup timeout (default none)\n");
+	fprintf(file, "   -I<cmgr> Cluster manager (default: auto)\n");
+	fprintf(file, "            Available cluster managers: ");
+#ifdef USE_COROSYNC
+	fprintf(file, "corosync ");
+#endif
+#ifdef USE_CMAN
+	fprintf(file, "cman ");
+#endif
+#ifdef USE_OPENAIS
+	fprintf(file, "openais ");
+#endif
+#ifdef USE_GULM
+	fprintf(file, "gulm ");
+#endif
 	fprintf(file, "\n");
 }
 
@@ -258,6 +275,7 @@
 	signed char opt;
 	int cmd_timeout = DEFAULT_CMD_TIMEOUT;
 	int start_timeout = 0;
+	if_type_t cluster_iface = IF_AUTO;
 	sigset_t ss;
 	int using_gulm = 0;
 	int debug_opt = 0;
@@ -266,7 +284,7 @@
 	/* Deal with command-line arguments */
 	opterr = 0;
 	optind = 0;
-	while ((opt = getopt(argc, argv, "?vVhd::t:RT:C")) != EOF) {
+	while ((opt = getopt(argc, argv, "?vVhd::t:RT:CI:")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -299,6 +317,9 @@
 				exit(1);
 			}
 			break;
+		case 'I':
+			cluster_iface = parse_cluster_interface(optarg);
+			break;
 		case 'T':
 			start_timeout = atoi(optarg);
 			if (start_timeout <= 0) {
@@ -365,7 +386,7 @@
 
 	/* Start the cluster interface */
 #ifdef USE_CMAN
-	if ((clops = init_cman_cluster())) {
+	if ((cluster_iface == IF_AUTO || cluster_iface == IF_CMAN) && (clops = init_cman_cluster())) {
 		max_csid_len = CMAN_MAX_CSID_LEN;
 		max_cluster_message = CMAN_MAX_CLUSTER_MESSAGE;
 		max_cluster_member_name_len = CMAN_MAX_NODENAME_LEN;
@@ -374,7 +395,7 @@
 #endif
 #ifdef USE_GULM
 	if (!clops)
-		if ((clops = init_gulm_cluster())) {
+		if ((cluster_iface == IF_AUTO || cluster_iface == IF_GULM) && (clops = init_gulm_cluster())) {
 			max_csid_len = GULM_MAX_CSID_LEN;
 			max_cluster_message = GULM_MAX_CLUSTER_MESSAGE;
 			max_cluster_member_name_len = GULM_MAX_CLUSTER_MEMBER_NAME_LEN;
@@ -382,24 +403,24 @@
 			syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to GULM");
 		}
 #endif
-#ifdef USE_OPENAIS
-	if (!clops)
-		if ((clops = init_openais_cluster())) {
-			max_csid_len = OPENAIS_CSID_LEN;
-			max_cluster_message = OPENAIS_MAX_CLUSTER_MESSAGE;
-			max_cluster_member_name_len = OPENAIS_MAX_CLUSTER_MEMBER_NAME_LEN;
-			syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to OpenAIS");
-		}
-#endif
 #ifdef USE_COROSYNC
 	if (!clops)
-		if ((clops = init_corosync_cluster())) {
+		if (((cluster_iface == IF_AUTO || cluster_iface == IF_COROSYNC) && (clops = init_corosync_cluster()))) {
 			max_csid_len = COROSYNC_CSID_LEN;
 			max_cluster_message = COROSYNC_MAX_CLUSTER_MESSAGE;
 			max_cluster_member_name_len = COROSYNC_MAX_CLUSTER_MEMBER_NAME_LEN;
 			syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to Corosync");
 		}
 #endif
+#ifdef USE_OPENAIS
+	if (!clops)
+		if ((cluster_iface == IF_AUTO || cluster_iface == IF_OPENAIS) && (clops = init_openais_cluster())) {
+			max_csid_len = OPENAIS_CSID_LEN;
+			max_cluster_message = OPENAIS_MAX_CLUSTER_MESSAGE;
+			max_cluster_member_name_len = OPENAIS_MAX_CLUSTER_MEMBER_NAME_LEN;
+			syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to OpenAIS");
+		}
+#endif
 
 	if (!clops) {
 		DEBUGLOG("Can't initialise cluster interface\n");
@@ -2008,3 +2029,20 @@
 	return clops->sync_unlock(resource, lockid);
 }
 
+static if_type_t parse_cluster_interface(char *ifname)
+{
+	if_type_t iface = IF_AUTO;
+
+	if (!strcmp(ifname, "auto"))
+		iface = IF_AUTO;
+	if (!strcmp(ifname, "cman"))
+		iface = IF_CMAN;
+	if (!strcmp(ifname, "gulm"))
+		iface = IF_GULM;
+	if (!strcmp(ifname, "openais"))
+		iface = IF_OPENAIS;
+	if (!strcmp(ifname, "corosync"))
+		iface = IF_COROSYNC;
+
+	return iface;
+}


