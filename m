From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:48 +0000 (GMT)
Subject: main - gcc-fanalyzer: notices 'du' could be NULL
Message-ID: <20210920132948.6D55D3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e15d1e53c181b804b12f059788ed111d42353be9
Commit:        e15d1e53c181b804b12f059788ed111d42353be9
Parent:        834f17bb3388ffe7f51aeede15d957a63bcda715
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 17 23:51:12 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 10:51:30 2021 +0200

gcc-fanalyzer: notices 'du' could be NULL

Ensure only nonNULL 'du' pointer is dereference altough the comment
to the last assign 'du' pointer already suggest 'NULL' case should not happen.
So just being explicit.

mer du
---
 lib/device/device_id.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 649c4bba9..742ce62bd 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -2144,7 +2144,8 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 			/* I don't think this would happen */
 			log_warn("WARNING: new device %s for PVID %s does not pass filter %s.",
 				 dev_name(dev), dil->pvid, dev_filtered_reason(dev));
-			du->dev = NULL;
+			if (du) /* Should not happen 'du' is NULL */
+				du->dev = NULL;
 			dev->flags &= ~DEV_MATCHED_USE_ID;
 		}
 	}


