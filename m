From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:30 +0000 (UTC)
Subject: master - lvmcache: copy just 32bytes
Message-ID: <20150508131630.26AC260759@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf5cb4af8e7722a4b29bff0caf23a1c5a167a360
Commit:        bf5cb4af8e7722a4b29bff0caf23a1c5a167a360
Parent:        87578b5d94a733b4b57b353c2430df32497a87a4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 11:28:22 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 13:31:59 2015 +0200

lvmcache: copy just 32bytes

Copy only bytes which fits.

vginfo->vgid  is  [ID_LEN + 1]
vgsummary->vgid has only [ID_LEN]

Reported by Coverity.
---
 WHATS_NEW            |    1 +
 lib/cache/lvmcache.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 41f8739..87ce45c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  Fix storing of vgid when caching metadata (2.02.118).
   Fix recursive lvm-config man page. (2.02.119)
   Refactor polldaemon interfaces to poll every operation by VG/LV couple
   Skip wait after testing in _wait_for_single_lv when polling finished
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 90e7b28..0d13c16 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2233,7 +2233,8 @@ int lvmcache_lookup_mda(struct lvmcache_vgsummary *vgsummary)
 			vgsummary->vgname = vginfo->vgname;
 			vgsummary->creation_host = vginfo->creation_host;
 			vgsummary->vgstatus = vginfo->status;
-			memcpy((char *)&vgsummary->vgid, vginfo->vgid, sizeof(vginfo->vgid));
+			/* vginfo->vgid has 1 extra byte then vgsummary->vgid */
+			memcpy(&vgsummary->vgid, vginfo->vgid, sizeof(vgsummary->vgid));
 
 			return 1;
 		}


