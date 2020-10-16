From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:07 +0000 (GMT)
Subject: stable-2.02 - lv_manip: add synchronization points
Message-ID: <20201016191107.9417F396EC5D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d2fc49e9957308e6c770c2a84f3a34b9b416d2b
Commit:        6d2fc49e9957308e6c770c2a84f3a34b9b416d2b
Parent:        d063ea27b46f2c3e2575a55576ea15e5957657c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 8 15:20:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

lv_manip: add synchronization points

---
 lib/metadata/lv_manip.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 97bab5256..945f5cb60 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7322,6 +7322,9 @@ out:
 			r = 0; /* Continue deactivating as many as possible. */
 		}
 
+	if (!sync_local_dev_names(vg->cmd))
+		log_debug("Failed to sync local device names after deactivation of wiped volumes.");
+
 	return r;
 }
 


