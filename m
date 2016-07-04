From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Jul 2016 15:41:55 +0000 (UTC)
Subject: master - dmeventd: improved logged messages from thin plugin
Message-ID: <20160704154155.C7D99611CF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=adc1fe4b3f84b341383d9737162397426e1a1295
Commit:        adc1fe4b3f84b341383d9737162397426e1a1295
Parent:        52be93c54bfedf16bb86472c03b6833d2be0efd1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 4 17:30:27 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 4 17:40:24 2016 +0200

dmeventd: improved logged messages from thin plugin

Show better names in logged messages.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index c27cf50..622910f 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -94,7 +94,7 @@ static int _has_unmountable_prefix(int major, int minor)
 		goto out;
 
 #if THIN_DEBUG
-	log_debug("Found LV (%u:%u) %s.",  major, minor, uuid);
+	log_debug("Found logical volume %s (%u:%u).", uuid, major, minor);
 #endif
 	r = 1;
 out:
@@ -246,13 +246,18 @@ static int _umount_device(char *buffer, unsigned major, unsigned minor,
 			  char *target, void *cb_data)
 {
 	struct mountinfo_s *data = cb_data;
+	char *words[10];
 
 	if ((major == data->info.major) && dm_bit(data->minors, minor)) {
-		log_info("Unmounting thin volume %s from %s.",
-			 data->device, target);
+		if (dm_split_words(buffer, DM_ARRAY_SIZE(words), 0, words) < DM_ARRAY_SIZE(words))
+			words[9] = NULL; /* just don't show device name */
+		log_info("Unmounting thin %s (%d:%d) of thin-pool %s (%u:%u) from mount point \"%s\".",
+			 words[9] ? : "", major, minor, data->device,
+			 data->info.major, data->info.minor,
+			 target);
 		if (!_run(UMOUNT_COMMAND, "-fl", target, NULL))
-			log_error("Failed to umount thin %s from %s: %s.",
-				  data->device, target, strerror(errno));
+			log_error("Failed to lazy umount thin %s (%d:%d) from %s: %s.",
+				  words[9], major, minor, target, strerror(errno));
 	}
 
 	return 1;


