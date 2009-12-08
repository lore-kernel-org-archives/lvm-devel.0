From: Milan Broz <mbroz@redhat.com>
Date: Tue,  8 Dec 2009 16:39:23 +0100
Subject: [PATCH 04/10] Get rid of magic masks in cluster locking code - clvmd part.
In-Reply-To: <cover.1260284754.git.mbroz@redhat.com>
References: <cover.1260284754.git.mbroz@redhat.com>
Message-ID: <c523359ee428aac9fdf03946ea93cb2e051005d7.1260284754.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

- do_command and lock_vg expect flags including HOLD_MASK (no change here)

Bug fixes:
- lock_vg should check for NONBLOCK on lock_cmd, flgas have this bit masked-out

- do_pre/post_command expect do not mask flag at all, this causes that
the code inside is never run! (see following patches, thes functions
expect plain command without HOLD flags)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/clvmd-command.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 2266a2b..e11f864 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -132,7 +132,7 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 
 	case CLVMD_CMD_LOCK_LV:
 		/* This is the biggie */
-		lock_cmd = args[0] & 0x3F;
+		lock_cmd = args[0] & (LCK_HOLD_MASK | LCK_SCOPE_MASK | LCK_TYPE_MASK);
 		lock_flags = args[1];
 		lockname = &args[2];
 		status = do_lock_lv(lock_cmd, lock_flags, lockname);
@@ -214,7 +214,7 @@ static int lock_vg(struct local_client *client)
 	client->bits.localsock.private = (void *)lock_hash;
     }
 
-    lock_cmd = args[0] & 0x3F;
+    lock_cmd = args[0] & (LCK_HOLD_MASK | LCK_SCOPE_MASK | LCK_TYPE_MASK);
     lock_flags = args[1];
     lockname = &args[2];
     DEBUGLOG("doing PRE command LOCK_VG '%s' at %x (client=%p)\n", lockname, lock_cmd, client);
@@ -237,7 +237,7 @@ static int lock_vg(struct local_client *client)
 	    lock_cmd &= ~LCK_TYPE_MASK;
 	    lock_cmd |= LCK_PREAD;
 	}
-	status = sync_lock(lockname, (int)lock_cmd, (lock_flags & LCK_NONBLOCK) ? LKF_NOQUEUE : 0, &lkid);
+	status = sync_lock(lockname, (int)lock_cmd, (lock_cmd & LCK_NONBLOCK) ? LKF_NOQUEUE : 0, &lkid);
 	if (status)
 	    status = errno;
 	else
@@ -277,7 +277,7 @@ int do_pre_command(struct local_client *client)
 		break;
 
 	case CLVMD_CMD_LOCK_LV:
-		lock_cmd = args[0];
+		lock_cmd = args[0] & (LCK_SCOPE_MASK | LCK_TYPE_MASK);
 		lock_flags = args[1];
 		lockname = &args[2];
 		status = pre_lock_lv(lock_cmd, lock_flags, lockname);
@@ -323,7 +323,7 @@ int do_post_command(struct local_client *client)
 		break;
 
 	case CLVMD_CMD_LOCK_LV:
-		lock_cmd = args[0];
+		lock_cmd = args[0] & (LCK_SCOPE_MASK | LCK_TYPE_MASK);
 		lock_flags = args[1];
 		lockname = &args[2];
 		status = post_lock_lv(lock_cmd, lock_flags, lockname);
-- 
1.6.5.4


