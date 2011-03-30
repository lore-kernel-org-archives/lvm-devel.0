From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 12:57:04 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/mm/pool-debug.c libd ...
Message-ID: <20110330125704.32651.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 12:57:03

Modified files:
	.              : WHATS_NEW_DM 
	libdm/mm       : pool-debug.c pool.c 

Log message:
	Word alignment for strings
	
	Align strdup char* allocation just on 2 bytes.
	It looks like wasting space to align strings on 8 bytes.
	(Could be even 1byte - but for hashing it might eventually get better
	perfomance - but probably hardly measurable).
	
	TODO: check on various architectures it's not making any problems.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.460&r2=1.461
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-debug.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW_DM	2011/03/30 12:14:36	1.460
+++ LVM2/WHATS_NEW_DM	2011/03/30 12:57:03	1.461
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Use word alignment for dm_pool_strdup() and dm_pool_strndup().
   Use dm_snprintf() to fix signess warning in dm_set_dev_dir().
   Use unsigned loop counter to fix signess warning in _other_node_ops().
   Fix const cast in dmsetup calls of dm_report_field_string().
--- LVM2/libdm/mm/pool-debug.c	2011/03/30 12:16:15	1.11
+++ LVM2/libdm/mm/pool-debug.c	2011/03/30 12:57:03	1.12
@@ -136,7 +136,7 @@
 	 * I don't think LVM will use anything but default
 	 * align.
 	 */
-	assert(alignment == DEFAULT_ALIGNMENT);
+	assert(alignment <= DEFAULT_ALIGNMENT);
 
 	if (!b) {
 		log_error("Out of memory");
--- LVM2/libdm/mm/pool.c	2011/03/10 14:49:01	1.6
+++ LVM2/libdm/mm/pool.c	2011/03/30 12:57:03	1.7
@@ -27,7 +27,7 @@
 
 char *dm_pool_strdup(struct dm_pool *p, const char *str)
 {
-	char *ret = dm_pool_alloc(p, strlen(str) + 1);
+	char *ret = dm_pool_alloc_aligned(p, strlen(str) + 1, 2);
 
 	if (ret)
 		strcpy(ret, str);
@@ -37,7 +37,7 @@
 
 char *dm_pool_strndup(struct dm_pool *p, const char *str, size_t n)
 {
-	char *ret = dm_pool_alloc(p, n + 1);
+	char *ret = dm_pool_alloc_aligned(p, n + 1, 2);
 
 	if (ret) {
 		strncpy(ret, str, n);


