From: Takahiro Yasui <tyasui@redhat.com>
Date: Tue, 23 Feb 2010 13:45:11 -0500
Subject: [RFC][PATCH 3/4] dm-crypt: update resume method for interruption of presuspend
Message-ID: <4B842237.7020202@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When suspend is interrupted after presuspend procedure, each
target needs to cancel all state changes done by its presuspend
procedure. As for the crypt target, there is nothing to be
canceled because the crypt target doesn't have a presuspend method.

The crypt target should skip crypt_preresume/crypt_resume method
when the target isn't suspended.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 drivers/md/dm-crypt.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux-2.6.33-rc1-dm/drivers/md/dm-crypt.c
===================================================================
--- linux-2.6.33-rc1-dm.orig/drivers/md/dm-crypt.c
+++ linux-2.6.33-rc1-dm/drivers/md/dm-crypt.c
@@ -1314,6 +1314,10 @@ static int crypt_preresume(struct dm_tar
 {
 	struct crypt_config *cc = ti->private;
 
+	/* Just returns if the state is not "suspended". */
+	if (!dm_suspended(ti))
+		return 0;
+
 	if (!test_bit(DM_CRYPT_KEY_VALID, &cc->flags)) {
 		DMERR("aborting resume - crypt key is not set.");
 		return -EAGAIN;
@@ -1326,6 +1330,10 @@ static void crypt_resume(struct dm_targe
 {
 	struct crypt_config *cc = ti->private;
 
+	/* Just returns if the state is not "suspended". */
+	if (!dm_suspended(ti))
+		return;
+
 	clear_bit(DM_CRYPT_SUSPENDED, &cc->flags);
 }
 


