From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:38:20 +0000 (UTC)
Subject: dev-dct-process-latest - WHATS_NEW for filter-related changes
Message-ID: <20140922153820.7617660EE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef6508e9a4ca7e9e2827b59c3e22f6442dcc72d0
Commit:        ef6508e9a4ca7e9e2827b59c3e22f6442dcc72d0
Parent:        30e0c0d863ed64b0ec74af6b4c0c0bfac39fccf4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Sep 13 17:34:13 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sat Sep 13 17:34:13 2014 +0200

WHATS_NEW for filter-related changes

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f127d7d..ac9d9a5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.112 - 
 =====================================
+  Demote an error to a warning when devices known to lvmetad are filtered out.
+  Re-order filter evaluation, making component filters global.
   Don't leak alloc_handle on raid target error path.
   Properly validate raid leg names.
   Archive metadata before starting their modification in raid target.


