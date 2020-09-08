From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Sep 2020 22:03:40 +0000 (GMT)
Subject: master - lv_manip: add synchronization points
Message-ID: <20200908220340.70A413953808@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e6bb772287a6d7f753b08780c7e913c98f5e307
Commit:        3e6bb772287a6d7f753b08780c7e913c98f5e307
Parent:        8d6f1f9768da5a66b8f5153d13c96f50f411155f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 8 15:20:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 8 21:23:03 2020 +0200

lv_manip: add synchronization points

---
 lib/metadata/lv_manip.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 284d0e52b..d72c49bea 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7750,6 +7750,9 @@ out:
 			r = 0; /* Continue deactivating as many as possible. */
 		}
 
+	if (!sync_local_dev_names(vg->cmd))
+		log_debug("Failed to sync local device names after deactivation of wiped volumes.");
+
 	return r;
 }
 


