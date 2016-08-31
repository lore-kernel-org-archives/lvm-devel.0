From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 31 Aug 2016 09:14:01 +0000 (UTC)
Subject: master - dmeventd: typo and debug name fix
Message-ID: <20160831091401.C65B6614B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b26604c8d84a189fc3ee276d6e8711a49eecd831
Commit:        b26604c8d84a189fc3ee276d6e8711a49eecd831
Parent:        16ed726610eca266bc6ef03989a156862ebf3d7a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 31 11:05:39 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 31 11:13:59 2016 +0200

dmeventd: typo and debug name fix

Fix 'raw' -> 'row' fix.
Consitently use thin pool as a type of monitored device in info message.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 622910f..d5a3a59 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -251,7 +251,7 @@ static int _umount_device(char *buffer, unsigned major, unsigned minor,
 	if ((major == data->info.major) && dm_bit(data->minors, minor)) {
 		if (dm_split_words(buffer, DM_ARRAY_SIZE(words), 0, words) < DM_ARRAY_SIZE(words))
 			words[9] = NULL; /* just don't show device name */
-		log_info("Unmounting thin %s (%d:%d) of thin-pool %s (%u:%u) from mount point \"%s\".",
+		log_info("Unmounting thin %s (%d:%d) of thin pool %s (%u:%u) from mount point \"%s\".",
 			 words[9] ? : "", major, minor, data->device,
 			 data->info.major, data->info.minor,
 			 target);
@@ -429,7 +429,7 @@ out:
 
 	if (state->fails >= MAX_FAILS) {
 		log_warn("WARNING: Dropping monitoring of %s. "
-			 "lvm2 command fails too often (%u times in raw).",
+			 "lvm2 command fails too often (%u times in row).",
 			 device, state->fails);
 		pthread_kill(pthread_self(), SIGALRM);
 	}
@@ -458,11 +458,11 @@ int register_device(const char *device,
 	state->data_percent_check = CHECK_MINIMUM;
 	*user = state;
 
-	log_info("Monitoring thin %s.", device);
+	log_info("Monitoring thin pool %s.", device);
 
 	return 1;
 bad:
-	log_error("Failed to monitor thin %s.", device);
+	log_error("Failed to monitor thin pool %s.", device);
 
 	return 0;
 }
@@ -476,7 +476,7 @@ int unregister_device(const char *device,
 	struct dso_state *state = *user;
 
 	dmeventd_lvm2_exit_with_pool(state);
-	log_info("No longer monitoring thin %s.", device);
+	log_info("No longer monitoring thin pool %s.", device);
 
 	return 1;
 }


