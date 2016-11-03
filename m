From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 16:49:47 +0000 (UTC)
Subject: master - log_info to log_warn
Message-ID: <20161103164947.54C1560F1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc19cc07f7a1aa4a45f6044a7eb4686f6d5dcf69
Commit:        cc19cc07f7a1aa4a45f6044a7eb4686f6d5dcf69
Parent:        e3775173b41f0cd4dfaeab84a235e167d9603618
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 31 18:00:53 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 17:49:07 2016 +0100

log_info to log_warn

Switch to log_warn level when we are reporting these message.
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index ee10874..7653413 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -107,7 +107,7 @@ static int _remove_failed_devices(const char *cmd_lvscan, const char *cmd_lvconv
 	int r;
 
 	if (!dmeventd_lvm2_run_with_lock(cmd_lvscan))
-		log_info("Re-scan of mirrored device failed.");
+		log_warn("WARNING: Re-scan of mirrored device failed.");
 
 	/* if repair goes OK, report success even if lvscan has failed */
 	r = dmeventd_lvm2_run_with_lock(cmd_lvconvert);
@@ -168,7 +168,7 @@ void process_event(struct dm_task *dmt,
 			break;
 		default:
 			/* FIXME Provide value then! */
-			log_info("Unknown event received.");
+			log_warn("WARNING: %s received unknown event.", device);
 		}
 	} while (next);
 }


