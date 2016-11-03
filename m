From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 16:49:45 +0000 (UTC)
Subject: master - cleanup: log_info to log_error
Message-ID: <20161103164945.44F8D60F1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e3775173b41f0cd4dfaeab84a235e167d9603618
Commit:        e3775173b41f0cd4dfaeab84a235e167d9603618
Parent:        ee13f265f043b47a1b023321fb9e8470fb5703c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 31 18:03:06 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 17:49:07 2016 +0100

cleanup: log_info to log_error

Switch to more appropriate logging level.
---
 WHATS_NEW                                     |    1 +
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |    2 +-
 lib/filters/filter-regex.c                    |    4 ++--
 lib/filters/filter-sysfs.c                    |    2 +-
 5 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 311f3b6..a5e6d45 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.167 - 
 ======================================
+  Use log_error in regex and sysfs filter to describe reason of failure.
   Fix blkdeactivate to deactivate dev stack if dev on top already unmounted.
   Prevent non-synced raid1 repair unless --force
   Prevent raid4 creation/conversion on non-supporting kernels
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a4dd6eb..17c370c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Log failure of raid device with log_error level.
   Use dm_log_with_errno and translate runtime to dm_log only when needed.
   Make log messages from dm and lvm library differnt from dmeventd.
   Notice and Info messages are again logged from dmeventd and its plugins.
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index ee18793..9df5f1d 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -76,7 +76,7 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 
 		/* if repair goes OK, report success even if lvscan has failed */
 		if (!dmeventd_lvm2_run_with_lock(state->cmd_lvconvert)) {
-			log_info("Repair of RAID device %s failed.", device);
+			log_error("Repair of RAID device %s failed.", device);
 			r = 0;
 		}
 	} else {
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index b8d229b..f7cc072 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -40,7 +40,7 @@ static int _extract_pattern(struct dm_pool *mem, const char *pat,
 		break;
 
 	default:
-		log_info("pattern must begin with 'a' or 'r'");
+		log_error("Pattern must begin with 'a' or 'r'.");
 		return 0;
 	}
 	pat++;
@@ -77,7 +77,7 @@ static int _extract_pattern(struct dm_pool *mem, const char *pat,
 	 */
 	ptr = r + strlen(r) - 1;
 	if (*ptr != sep) {
-		log_info("invalid separator at end of regex");
+		log_error("Invalid separator at end of regex.");
 		return 0;
 	}
 	*ptr = '\0';
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index 6f566bc..6dacd5d 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -168,7 +168,7 @@ static int _parse_dev(const char *file, FILE *fp, dev_t *result)
 	}
 
 	if (sscanf(buffer, "%u:%u", &major, &minor) != 2) {
-		log_info("sysfs device file not correct format");
+		log_error("Incorrect format for sysfs device file: %s.", file);
 		return 0;
 	}
 


