From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:28 +0000 (UTC)
Subject: master - activation: _lv_active returns 0 on error
Message-ID: <20160623130128.C9AF6605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb51be4fbee95d76b53e5255242a8032c3028aa2
Commit:        eb51be4fbee95d76b53e5255242a8032c3028aa2
Parent:        af36f5ad369ebf4c1d768145a827436ccef22f63
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 22 23:04:53 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:55:35 2016 +0200

activation: _lv_active returns 0 on error

We have only 2 users of _lv_active() - one was already checking for ==1
while the other use (_lv_is_active()) could have take '-1' as a sign of having
an LV active. So return 0 and log_debug also the reason while detection
has failed (i.e. in case  --driverload n  - it's kind of expectable,
but might have confused user seeing just <backtrace>).
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6788e6a..7cd46d1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Rerurn 0 (inactive) when status cannot be queried in _lv_active().
   Switch to log_warn() for failing activation status query.
   Refactor lvconvert argument handling code.
   Add --logonly option to report only cmd log for a command, not other reports.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 8892a2a..7f5d36f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1266,8 +1266,10 @@ static int _lv_active(struct cmd_context *cmd, const struct logical_volume *lv)
 	struct lvinfo info;
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0)) {
-		stack;
-		return -1;
+		log_debug("Cannot determine activation status of %s%s.",
+			  display_lvname(lv),
+			  activation() ? "" : " (no device driver)");
+		return 0;
 	}
 
 	return info.exists;


