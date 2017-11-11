From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Nov 2017 19:03:16 -0500
Subject: master - reload: do not take backup with suspended devices
Message-ID: <201711110003.vAB03G8n009580@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=55b8204ca3ca9fe05bc04cb1e1f3fc24ebbdfe48
Commit:        55b8204ca3ca9fe05bc04cb1e1f3fc24ebbdfe48
Parent:        1ac7fde67b10c2bdfa37d1cf3f2ce48033f27baf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 10 13:28:33 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 11 00:58:11 2017 +0100

reload: do not take backup with suspended devices

If the suspend/resume sequence would leave some device in suspend
for possible later resume, backup cannot be takes (fs holding backups
could be still frozen in critical section())
---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 41b52ec..d06b459 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6413,7 +6413,7 @@ static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
 		r = 0;
 	}
 
-	if (do_backup)
+	if (do_backup && !critical_section())
 		backup(vg);
 
 	return r;


