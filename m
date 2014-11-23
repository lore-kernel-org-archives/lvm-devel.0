From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 23 Nov 2014 23:03:14 +0000 (UTC)
Subject: master - Update WHATS_NEW.
Message-ID: <20141123230314.619CB60A31@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14472d62ba459db629221e83235720dde7fc4e49
Commit:        14472d62ba459db629221e83235720dde7fc4e49
Parent:        a6a7a3a074692a66d065d19e58e6e170233ab9e9
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Nov 23 23:30:27 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 23 23:30:27 2014 +0100

Update WHATS_NEW.

---
 WHATS_NEW    |    1 +
 WHATS_NEW_DM |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 19f1d2a..fc6ba69 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -8,6 +8,7 @@ Version 2.02.113 -
   Failed recovery returns FAILED_RECOVERY status flag for vg_read().
   Exit with non-zero status code when pvck encounters a problem.
   Fix clean_tree after activation/resume for cache target (2.02.112).
+  Add --cachepolicy and --cachesettings options to lvchange.
 
 Version 2.02.112 - 11th November 2014
 =====================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 0de5b89..ba4e679 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -2,6 +2,7 @@ Version 1.02.92 -
 ====================================
   Fix memory corruption with sorting empty string lists (1.02.86).
   Fix man dmsetup.8 syntax warning of Groff
+  Relax rules in the config file parser.
 
 Version 1.02.91 - 11th November 2014
 ====================================


