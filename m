From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 22:23:14 -0000
Subject: LVM2 daemons/clvmd/clvmd-command.c lib/cache/l ...
Message-ID: <20120223222314.4629.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 22:23:13

Modified files:
	daemons/clvmd  : clvmd-command.c 
	lib/cache      : lvmcache.c 

Log message:
	Remaing code suffling
	
	Move declaration to the front of function to follow coding rules.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/daemons/clvmd/clvmd-command.c	2012/01/25 22:20:11	1.64
+++ LVM2/daemons/clvmd/clvmd-command.c	2012/02/23 22:23:12	1.65
@@ -341,23 +341,25 @@
 /* Called when the client is about to be deleted */
 void cmd_client_cleanup(struct local_client *client)
 {
-    if (client->bits.localsock.private) {
-
 	struct dm_hash_node *v;
-	struct dm_hash_table *lock_hash =
-	    (struct dm_hash_table *)client->bits.localsock.private;
+	struct dm_hash_table *lock_hash;
+	int lkid;
+	char *lockname;
 
-	dm_hash_iterate(v, lock_hash) {
-		int lkid = (int)(long)dm_hash_get_data(lock_hash, v);
-		char *lockname = dm_hash_get_key(lock_hash, v);
+	if (!client->bits.localsock.private)
+		return;
 
+	lock_hash = (struct dm_hash_table *)client->bits.localsock.private;
+
+	dm_hash_iterate(v, lock_hash) {
+		lkid = (int)(long)dm_hash_get_data(lock_hash, v);
+		lockname = dm_hash_get_key(lock_hash, v);
 		DEBUGLOG("cleanup: Unlocking lock %s %x\n", lockname, lkid);
 		sync_unlock(lockname, lkid);
 	}
 
 	dm_hash_destroy(lock_hash);
 	client->bits.localsock.private = 0;
-    }
 }
 
 
--- LVM2/lib/cache/lvmcache.c	2012/02/23 13:11:08	1.127
+++ LVM2/lib/cache/lvmcache.c	2012/02/23 22:23:13	1.128
@@ -452,6 +452,8 @@
 	struct dm_list *devh, *tmp;
 	struct dm_list devs;
 	struct device_list *devl;
+	struct volume_group *vg;
+	const struct format_type *fmt;
 	char vgid_found[ID_LEN + 1] __attribute__((aligned(8)));
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
@@ -459,9 +461,8 @@
 			return NULL; /* too bad */
 		/* If we don't have the info but we have lvmetad, we can ask
 		 * there before failing. */
-		struct volume_group *vg = lvmetad_vg_lookup(cmd, vgname, vgid);
-		if (vg) {
-			const struct format_type *fmt = vg->fid->fmt;
+		if ((vg = lvmetad_vg_lookup(cmd, vgname, vgid))) {
+			fmt = vg->fid->fmt;
 			release_vg(vg);
 			return fmt;
 		}


