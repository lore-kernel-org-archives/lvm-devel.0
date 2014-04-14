From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:03 +0000 (UTC)
Subject: master - pvmove: remove locked flag from error pvmove0
Message-ID: <20140414110603.6AB62609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84ff3ae703ec7d2859398f01eee726134c543723
Commit:        84ff3ae703ec7d2859398f01eee726134c543723
Parent:        45f45c9932840c4bc2d55a1d016269b3167e0450
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 10 20:31:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 12:52:32 2014 +0200

pvmove: remove locked flag from error pvmove0

When pvmove0 is finished, it replaces temporarily pvmove0
with error segment, however in this case, pvmove0 remains
unremovable in case pvmove --abort is interrupted in this
moment - since it's not a pvmove anymore and normal
lvremove can't be used to remove LOCKED lv.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 100b1cb..e7e74ed 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Remove LOCKED flag for pvmove replaced with error target.
   Return invalid command when specifying negative polling interval.
 
 Version 2.02.106 - 10th April 2014
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 18fa7e6..0d87b70 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -873,7 +873,7 @@ int replace_lv_with_error_segment(struct logical_volume *lv)
 	 * an error segment, we should also clear any flags
 	 * that suggest it is anything other than "error".
 	 */
-	lv->status &= ~(MIRRORED|PVMOVE);
+	lv->status &= ~(MIRRORED|PVMOVE|LOCKED);
 
 	/* FIXME: Should we bug if we find a log_lv attached? */
 


