From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 16:17:59 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20110218161759.1911.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 16:17:57

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 
	tools          : dmsetup.c vgconvert.c 

Log message:
	Fix gcc warnings for unused variables
	
	Put dead assigment code into comment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1921&r2=1.1922
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW	2011/02/18 15:02:25	1.1921
+++ LVM2/WHATS_NEW	2011/02/18 16:17:56	1.1922
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix gcc warnings for unused variables.
   Add stack backtraces for error paths in process_each_lv().
   Fixing some const cast gcc warnings in the code.
   Use char* arithmetic in _text_write(), _text_read() & send_message().
--- LVM2/daemons/clvmd/clvmd-command.c	2011/02/04 19:18:17	1.52
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/02/18 16:17:56	1.53
@@ -185,7 +185,6 @@
     struct clvm_header *header =
 	(struct clvm_header *) client->bits.localsock.cmd;
     unsigned char lock_cmd;
-    unsigned char lock_flags;
     int lock_mode;
     char *args = header->node + strlen(header->node) + 1;
     int lkid;
@@ -207,7 +206,7 @@
 
     lock_cmd = args[0] & (LCK_NONBLOCK | LCK_HOLD | LCK_SCOPE_MASK | LCK_TYPE_MASK);
     lock_mode = ((int)lock_cmd & LCK_TYPE_MASK);
-    lock_flags = args[1];
+    /* lock_flags = args[1]; */
     lockname = &args[2];
     DEBUGLOG("doing PRE command LOCK_VG '%s' at %x (client=%p)\n", lockname, lock_cmd, client);
 
--- LVM2/tools/dmsetup.c	2011/02/04 22:17:55	1.153
+++ LVM2/tools/dmsetup.c	2011/02/18 16:17:57	1.154
@@ -2998,7 +2998,6 @@
 static int _process_losetup_switches(const char *base, int *argc, char ***argv,
 				     const char *dev_dir)
 {
-	static int ind;
 	int c;
 	int encrypt_loop = 0, delete = 0, find = 0, show_all = 0;
 	char *device_name = NULL;
@@ -3013,8 +3012,8 @@
 
 	optarg = 0;
 	optind = OPTIND_INIT;
-	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "ade:fo:v",
-					    long_options, NULL)) != -1 ) {
+	while ((c = GETOPTLONG_FN(*argc, *argv, "ade:fo:v",
+				  long_options, NULL)) != -1 ) {
 		if (c == ':' || c == '?')
 			return 0;
 		if (c == 'a')
--- LVM2/tools/vgconvert.c	2010/08/17 16:25:35	1.44
+++ LVM2/tools/vgconvert.c	2011/02/18 16:17:57	1.45
@@ -26,7 +26,7 @@
 	struct dm_list mdas;
 	int pvmetadatacopies = 0;
 	uint64_t pvmetadatasize = 0;
-	uint64_t pe_end = 0, pe_start = 0;
+	uint64_t pe_start = 0;
 	struct pv_list *pvl;
 	int change_made = 0;
 	struct lvinfo info;
@@ -119,8 +119,7 @@
 		existing_pv = pvl->pv;
 
 		pe_start = pv_pe_start(existing_pv);
-		pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv)
-		    + pe_start - 1;
+		/* pe_end = pv_pe_count(existing_pv) * pv_pe_size(existing_pv) + pe_start - 1; */
 
 		dm_list_init(&mdas);
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),


