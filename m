From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:55:43 +0000 (UTC)
Subject: master - raid: lvconvert uses transient check for raid
Message-ID: <20161123165543.BE44C60F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=851095a6af7a5a1343d9eb2aa8a5c9e08f9759b3
Commit:        851095a6af7a5a1343d9eb2aa8a5c9e08f9759b3
Parent:        23809379babf96459ae7135114b9c6302c9a014e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 21 14:54:51 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:46:50 2016 +0100

raid: lvconvert uses transient check for raid

Also check if the raid status isn't teling us there is something wrong
with any raid image device.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9414b03..b7a5e82 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.168 - 
 ====================================
+  Use transient raid check before repairing raid volume.
   Implement transient status check for raid volumes.
   Only log msg as debug if lvm2-lvmdbusd unit missing for D-Bus notification.
   Missing stripe filler now could be also 'zero'.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d6824d8..ceeff2d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2068,6 +2068,9 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 0;
 		}
 
+		if (!lv_check_transient(lv)) /* TODO check this in lib for all commands? */
+			stack; /* TODO: break here upon fail or always try to fix it? */
+
 		_lvconvert_raid_repair_ask(cmd, lp, &replace);
 
 		if (replace) {


