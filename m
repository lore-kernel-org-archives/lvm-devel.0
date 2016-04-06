From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  6 Apr 2016 09:55:38 +0000 (UTC)
Subject: master - libdm: improve debug message with ioctl
Message-ID: <20160406095538.7DDB160FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=261a85ced94e2f4ed7c3f01d7d0a7624032e2697
Commit:        261a85ced94e2f4ed7c3f01d7d0a7624032e2697
Parent:        5b2227c2c10c2f762e238fedb756850fe4ac5d5d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 5 14:59:59 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 6 11:31:02 2016 +0200

libdm: improve debug message with ioctl

Make the debug message a less difficult to read:
Ioctl shows  [ noopencount flush ] instead of cryptic [NF].
---
 libdm/ioctl/libdm-iface.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 6111cb0..8259a78 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1814,7 +1814,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 	}
 
 	log_debug_activation("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
-			     "%s%c%c%s%s%s%s%s%s%s %.0" PRIu64 " %s [%u] (*%u)",
+			     "%s[ %s%s%s%s%s%s%s%s%s] %.0" PRIu64 " %s [%u] (*%u)",
 			     _cmd_data_v4[dmt->type].name,
 			     dmt->new_uuid ? "UUID " : "",
 			     dmi->name, dmi->uuid, dmt->newname ? " " : "",
@@ -1825,15 +1825,15 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 			     dmt->minor > 0 ? dmt->minor : 0,
 			     dmt->major > 0 && dmt->minor == 0 ? "0" : "",
 			     dmt->major > 0 ? ") " : "",
-			     dmt->no_open_count ? 'N' : 'O',
-			     dmt->no_flush ? 'N' : 'F',
-			     dmt->read_only ? "R" : "",
-			     dmt->skip_lockfs ? "S " : "",
-			     dmt->retry_remove ? "T " : "",
-			     dmt->deferred_remove ? "D " : "",
-			     dmt->secure_data ? "W " : "",
-			     dmt->query_inactive_table ? "I " : "",
-			     dmt->enable_checks ? "C" : "",
+			     dmt->no_open_count ? "noopencount " : "opencount ",
+			     dmt->no_flush ? "noflush " : "flush ",
+			     dmt->read_only ? "readonly " : "",
+			     dmt->skip_lockfs ? "skiplockfs " : "",
+			     dmt->retry_remove ? "retryremove " : "",
+			     dmt->deferred_remove ? "defferedremove " : "",
+			     dmt->secure_data ? "securedata " : "",
+			     dmt->query_inactive_table ? "inactive " : "",
+			     dmt->enable_checks ? "enablechecks " : "",
 			     dmt->sector, _sanitise_message(dmt->message),
 			     dmi->data_size, retry_repeat_count);
 #ifdef DM_IOCTLS


