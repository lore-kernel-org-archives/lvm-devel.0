From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Nov 2015 13:41:44 +0000 (UTC)
Subject: master - cache: enable raid conversion for _cdata and _cmeta
Message-ID: <20151119134144.5594B616A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1608345dffd912dd591d71a147c5acf587cf7fe
Commit:        d1608345dffd912dd591d71a147c5acf587cf7fe
Parent:        6f002c29a56d4e80ff7ebc9b8a5334c2599e663a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 19 13:30:55 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 19 14:38:36 2015 +0100

cache: enable raid conversion for _cdata and _cmeta

Since thin-pool supports convertion of data and metadata LV,
enable the same for cache data and metadata LV.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d5a4a3b..0519527 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Allow lvconvert cache pools' data and metadata LV to raid.
   Fix reading of old metadata with missing cache policy or mode settings.
   Issue error if external_device_info_source=udev and udev db record incomplete.
   Fix passing of 32bit values through daemons (mostly lvmlockd).
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3cfd915..19ee607 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -199,6 +199,8 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	    !arg_count(cmd, splitmirrors_ARG) &&
 	    !strstr(lp->lv_name, "_tdata") &&
 	    !strstr(lp->lv_name, "_tmeta") &&
+	    !strstr(lp->lv_name, "_cdata") &&
+	    !strstr(lp->lv_name, "_cmeta") &&
 	    !apply_lvname_restrictions(lp->lv_name))
 		return_0;
 


