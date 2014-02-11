From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:19 +0000 (UTC)
Subject: master - raid: use unsigned 64b constant for shift
Message-ID: <20140211180119.4F6BA60D1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a21dcebac02884615b80fbe9d276991a50dc66b
Commit:        8a21dcebac02884615b80fbe9d276991a50dc66b
Parent:        1a5062c9a7136f93a00b998ff0de1a32bb347b5f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 9 21:34:55 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 18:47:15 2014 +0100

raid: use unsigned 64b constant for shift

---
 WHATS_NEW       |    1 +
 lib/raid/raid.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 918123f..a64f961 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Use correctly signed 64b constant when selecting raid volumes.
   Add systemd native service for clvmd, cmirrord and clustered LV activation.
   Remove ExecReload from lvmetad systemd unit: lvmetad -R undefined. (2.02.98)
   Do not fork lvmetad if running under systemd.
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 956472e..9f7bbd1 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -221,11 +221,11 @@ static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
 
 	for (s = 0; s < seg->area_count; s++)
 		if (seg_lv(seg, s)->status & LV_REBUILD)
-			rebuilds |= 1 << s;
+			rebuilds |= 1ULL << s;
 
 	for (s = 0; s < seg->area_count; s++)
 		if (seg_lv(seg, s)->status & LV_WRITEMOSTLY)
-			writemostly |= 1 << s;
+			writemostly |= 1ULL << s;
 
 	if (mirror_in_sync())
 		flags = DM_NOSYNC;


