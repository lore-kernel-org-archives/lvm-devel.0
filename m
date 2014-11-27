From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 27 Nov 2014 19:32:18 +0000 (UTC)
Subject: master - Update WHATS_NEW.
Message-ID: <20141127193218.C466B60BBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=530ebd8976bc08fdbaac7c132301fdde1e66ed8f
Commit:        530ebd8976bc08fdbaac7c132301fdde1e66ed8f
Parent:        5b2726fc6142c734e06fa8b49ad856b2e47da9fc
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Nov 27 20:23:57 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 27 20:23:57 2014 +0100

Update WHATS_NEW.

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d90cd94..89f0ebb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.114 - 
 =====================================
+  Add --cachepolicy and --cachesettings to lvcreate.
   Fix regression when parsing /dev/mapper dir (2.02.112).
   Fix missing rounding to 64KB when estimating optimal thin pool chunk size.
   Fix typo in clvmd initscript causing CLVMD_STOP_TIMEOUT variable to be ignored.


