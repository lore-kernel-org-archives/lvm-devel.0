From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 13:06:58 -0000
Subject: LVM2/daemons common/daemon-shared.c lvmetad/lv ...
Message-ID: <20120125130658.9542.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 13:06:57

Modified files:
	daemons/common : daemon-shared.c 
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Clean var declarations to the front of the function

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-shared.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/daemons/common/daemon-shared.c	2012/01/19 15:59:51	1.9
+++ LVM2/daemons/common/daemon-shared.c	2012/01/25 13:06:57	1.10
@@ -57,6 +57,7 @@
  * TODO use select on EWOULDBLOCK/EAGAIN to avoid useless spinning
  */
 int write_buffer(int fd, const char *buffer, int length) {
+	static const char terminate[] = "\n##\n";
 	int done = 0;
 	int written = 0;
 write:
@@ -73,7 +74,7 @@
 				break; /* done */
 		}
 	}
-	const char *terminate = "\n##\n";
+
 	buffer = terminate;
 	length = 4;
 	written = 0;
--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/01/16 08:25:32	1.29
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/01/25 13:06:57	1.30
@@ -167,6 +167,10 @@
 
 static response vg_lookup(lvmetad_state *s, request r)
 {
+	struct dm_config_tree *cft;
+	struct dm_config_node *metadata, *n;
+	response res = { .buffer = NULL };
+
 	const char *uuid = daemon_request_str(r, "uuid", NULL),
 		   *name = daemon_request_str(r, "name", NULL);
 	debug("vg_lookup: uuid = %s, name = %s\n", uuid, name);
@@ -185,15 +189,13 @@
 	if (!uuid)
 		return daemon_reply_simple("failed", "reason = %s", "VG not found", NULL);
 
-	struct dm_config_tree *cft = lock_vg(s, uuid);
+	cft = lock_vg(s, uuid);
 	if (!cft || !cft->root) {
 		unlock_vg(s, uuid);
 		return daemon_reply_simple("failed", "reason = %s", "UUID not found", NULL);
 	}
 
-	struct dm_config_node *metadata = cft->root, *n;
-	response res = { .buffer = NULL };
-
+	metadata = cft->root;
 	res.cft = dm_config_create();
 
 	/* The response field */
@@ -284,9 +286,11 @@
 /* A pvid map lock needs to be held. */
 static int remove_metadata(lvmetad_state *s, const char *vgid)
 {
+	struct dm_config_tree *old;
+	const char *oldname;
 	lock_vgs(s);
-	struct dm_config_tree *old = dm_hash_lookup(s->vgs, vgid);
-	const char *oldname = dm_hash_lookup(s->vg_names, vgid);
+	old = dm_hash_lookup(s->vgs, vgid);
+	oldname = dm_hash_lookup(s->vg_names, vgid);
 	unlock_vgs(s);
 
 	if (!old)
@@ -310,15 +314,17 @@
 	struct dm_config_tree *cft;
 	struct dm_config_tree *old;
 	int retval = 0;
+	int seq;
+	int haveseq = -1;
+	const char *oldname = NULL;
+	const char *vgid;
 
 	lock_vgs(s);
 	old = dm_hash_lookup(s->vgs, _vgid);
 	lock_vg(s, _vgid);
 	unlock_vgs(s);
 
-	int seq = dm_config_find_int(metadata, "metadata/seqno", -1);
-	int haveseq = -1;
-	const char *oldname = NULL;
+	seq = dm_config_find_int(metadata, "metadata/seqno", -1);
 
 	if (old) {
 		haveseq = dm_config_find_int(old->root, "metadata/seqno", -1);
@@ -348,7 +354,7 @@
 	cft = dm_config_create();
 	cft->root = dm_config_clone_node(cft, metadata, 0);
 
-	const char *vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
+	vgid = dm_config_find_str(cft->root, "metadata/id", NULL);
 
 	if (!vgid || !name) {
 		debug("Name '%s' or uuid '%s' missing!\n", name, vgid);


