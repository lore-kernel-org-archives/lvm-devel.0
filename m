From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:26 +0000 (UTC)
Subject: master - activation: switch to warning
Message-ID: <20160623130126.B350D605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af36f5ad369ebf4c1d768145a827436ccef22f63
Commit:        af36f5ad369ebf4c1d768145a827436ccef22f63
Parent:        751163a74375cc3bfc9f338f1317f14a23798812
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 21 15:16:03 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:53:59 2016 +0200

activation: switch to warning

Since this function does not have a way to return error use correct
reporting level as warning.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ce77b6c..6788e6a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Switch to log_warn() for failing activation status query.
   Refactor lvconvert argument handling code.
   Add --logonly option to report only cmd log for a command, not other reports.
   Add log/command_log_selection to configure default selection used on cmd log.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 089af53..8892a2a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1454,9 +1454,9 @@ static int _lv_is_active(const struct logical_volume *lv,
 	 * Old users of this function will never be affected by this,
 	 * since they are only concerned about active vs. not active.
 	 * New users of this function who specifically ask for 'exclusive'
-	 * will be given an error message.
+	 * will be given a warning message.
 	 */
-	log_error("Unable to determine exclusivity of %s.", display_lvname(lv));
+	log_warn("WARNING: Unable to determine exclusivity of %s.", display_lvname(lv));
 
 	e = 0;
 


