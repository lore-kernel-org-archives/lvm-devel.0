From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jan 2017 14:56:37 +0000 (UTC)
Subject: master - cache: resize is still unsupported
Message-ID: <20170105145637.C0CAA60E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e9c03cbbcf102029d11f312e1cd1d20284b6d03
Commit:        3e9c03cbbcf102029d11f312e1cd1d20284b6d03
Parent:        1f5dde38a7ec18d86c38c0b7e1cb2a953ea5cf44
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 5 15:32:25 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 5 15:34:22 2017 +0100

cache: resize is still unsupported

During rework of resize code this validation check
has been lost (in my resize branch). Upstream
is still not supporting resize of any cache type LV
so needs to be prevented.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5fb5904..3fde645 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Restore check preventing resize of cache type volumes (2.02.158).
   Add missing udev sync when flushing dirty cache content.
   vgchange -p accepts only uint32 numbers.
   Report thin LV date for merged LV when the merge is in progress.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9759cda..a954bf7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4687,6 +4687,11 @@ static int _lvresize_check(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_is_cache_type(lv)) {
+		log_error("Unable to resize logical volumes of cache type.");
+		return 0;
+	}
+
 	if (!lv_is_visible(lv) &&
 	    !lv_is_thin_pool_metadata(lv) &&
 	    !lv_is_lockd_sanlock_lv(lv)) {


