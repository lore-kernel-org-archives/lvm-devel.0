From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sun, 16 Aug 2015 00:17:55 +0000 (UTC)
Subject: master - WHATS_NEW: Update.
Message-ID: <20150816001755.6B44760F4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b297d78367c2a9395bcc6abc7484763368979842
Commit:        b297d78367c2a9395bcc6abc7484763368979842
Parent:        4a6d5e2012cbcf40842b5ef051347694bbf5ca04
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Aug 16 01:16:16 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Aug 16 01:16:16 2015 +0100

WHATS_NEW: Update.

---
 WHATS_NEW    |    7 +++----
 WHATS_NEW_DM |    6 +++---
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1e34e1c..dbb78d6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,10 +1,9 @@
 Version 2.02.128 - 
 ===================================
   Check for valid cache mode in validation of cache segment.
-  Enhance internal API cache_set_mode() and cache_set_policy().
-  Enhance toollib's get_cache_params().
-  Runtime detect presence of cache smq policy.
-  Add demo cache-mq  and cache-smq profiles.
+  Change internal interface handling cache mode and policy.
+  When no cache policy specified, prefer smq (if available) over mq.
+  Add demo cache-mq and cache-smq profiles.
   Add cmd profilable allocation/cache_policy,cache_settings,cache_mode.
   Require cache_check 0.5.4 for use of --clear-needs-check-flag.
   Fix lvmetad udev rules to not override SYSTEMD_WANTS, add the service instead.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8e816a0..870ffb2 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,8 +1,8 @@
 Version 1.02.105 - 
 ===================================
-  Fix 'stats list -o all' segfault
-  Separate statistics fields from region information fields
-  Add interval and interval_ns fields to DR_STATS reports.
+  Fix 'dmstats list -o all' segfault.
+  Separate dmstats statistics fields from region information fields.
+  Add interval and interval_ns fields to dmstats reports.
   Do not include internal glibc headers in libdm-timestamp.c (1.02.104)
   Exit immediately if no device is supplied to dmsetup wipe_table.
   Suppress dmsetup report headings when no data is output. (1.02.104)


