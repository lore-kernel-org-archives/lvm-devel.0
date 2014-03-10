From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:02 +0000 (UTC)
Subject: master - cleanup: clvmd reindent lock_vg code
Message-ID: <20140310112702.AA2DF60CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cbca815dc44e805d6e4cc138c28af73f1e47432a
Commit:        cbca815dc44e805d6e4cc138c28af73f1e47432a
Parent:        7a6c0e2425432cf6aa690709a985f6208f930ef6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 7 20:24:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:09 2014 +0100

cleanup: clvmd reindent lock_vg code

Code had wrong indent level, improve readability.
---
 daemons/clvmd/clvmd-command.c |  102 +++++++++++++++++++---------------------
 1 files changed, 48 insertions(+), 54 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 5d93f38..1ed1513 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -188,60 +188,54 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 
 static int lock_vg(struct local_client *client)
 {
-    struct dm_hash_table *lock_hash;
-    struct clvm_header *header =
-	(struct clvm_header *) client->bits.localsock.cmd;
-    unsigned char lock_cmd;
-    int lock_mode;
-    char *args = header->node + strlen(header->node) + 1;
-    int lkid;
-    int status = 0;
-    char *lockname;
-
-    /* Keep a track of VG locks in our own hash table. In current
-       practice there should only ever be more than two VGs locked
-       if a user tries to merge lots of them at once */
-    if (client->bits.localsock.private) {
-	lock_hash = (struct dm_hash_table *)client->bits.localsock.private;
-    }
-    else {
-	lock_hash = dm_hash_create(3);
-	if (!lock_hash)
-	    return ENOMEM;
-	client->bits.localsock.private = (void *)lock_hash;
-    }
-
-    lock_cmd = args[0] & (LCK_NONBLOCK | LCK_HOLD | LCK_SCOPE_MASK | LCK_TYPE_MASK);
-    lock_mode = ((int)lock_cmd & LCK_TYPE_MASK);
-    /* lock_flags = args[1]; */
-    lockname = &args[2];
-    DEBUGLOG("doing PRE command LOCK_VG '%s' at %x (client=%p)\n", lockname, lock_cmd, client);
-
-    if (lock_mode == LCK_UNLOCK) {
-
-	lkid = (int)(long)dm_hash_lookup(lock_hash, lockname);
-	if (lkid == 0)
-	    return EINVAL;
-
-	status = sync_unlock(lockname, lkid);
-	if (status)
-	    status = errno;
-	else
-	    dm_hash_remove(lock_hash, lockname);
-    }
-    else {
-	/* Read locks need to be PR; other modes get passed through */
-	if (lock_mode == LCK_READ)
-	    lock_mode = LCK_PREAD;
-	status = sync_lock(lockname, lock_mode, (lock_cmd & LCK_NONBLOCK) ? LCKF_NOQUEUE : 0, &lkid);
-	if (status)
-	    status = errno;
-	else
-	    if (!dm_hash_insert(lock_hash, lockname, (void *)(long)lkid))
-                    return ENOMEM;
-    }
-
-    return status;
+	struct dm_hash_table *lock_hash;
+	struct clvm_header *header =
+		(struct clvm_header *) client->bits.localsock.cmd;
+	unsigned char lock_cmd;
+	int lock_mode;
+	char *args = header->node + strlen(header->node) + 1;
+	int lkid;
+	int status;
+	char *lockname;
+
+	/*
+	 * Keep a track of VG locks in our own hash table. In current
+	 * practice there should only ever be more than two VGs locked
+	 * if a user tries to merge lots of them at once
+	 */
+	if (!client->bits.localsock.private) {
+		if (!(lock_hash = dm_hash_create(3)))
+			return ENOMEM;
+		client->bits.localsock.private = (void *) lock_hash;
+	} else
+		lock_hash = (struct dm_hash_table *) client->bits.localsock.private;
+
+	lock_cmd = args[0] & (LCK_NONBLOCK | LCK_HOLD | LCK_SCOPE_MASK | LCK_TYPE_MASK);
+	lock_mode = ((int) lock_cmd & LCK_TYPE_MASK);
+	/* lock_flags = args[1]; */
+	lockname = &args[2];
+	DEBUGLOG("doing PRE command LOCK_VG '%s' at %x (client=%p)\n", lockname, lock_cmd, client);
+
+	if (lock_mode == LCK_UNLOCK) {
+		if (!(lkid = (int) (long) dm_hash_lookup(lock_hash, lockname)))
+			return EINVAL;
+
+		if ((status = sync_unlock(lockname, lkid)))
+			status = errno;
+		else
+			dm_hash_remove(lock_hash, lockname);
+	} else {
+		/* Read locks need to be PR; other modes get passed through */
+		if (lock_mode == LCK_READ)
+			lock_mode = LCK_PREAD;
+
+		if ((status = sync_lock(lockname, lock_mode, (lock_cmd & LCK_NONBLOCK) ? LCKF_NOQUEUE : 0, &lkid)))
+			status = errno;
+		else if (!dm_hash_insert(lock_hash, lockname, (void *) (long) lkid))
+			return ENOMEM;
+	}
+
+	return status;
 }
 
 


