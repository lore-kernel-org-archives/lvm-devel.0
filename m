From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:49:55 +0000 (UTC)
Subject: master - WHATS_NEW: lvscan --cache, dmeventd RAID + lvmetad
Message-ID: <20140722204955.95B5B614D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=66686a5bc5ec09a48b0e549f5539424cbf2c7de8
Commit:        66686a5bc5ec09a48b0e549f5539424cbf2c7de8
Parent:        5dc6671bb550f4b480befee03d234373d08e188a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 22 22:33:42 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jul 22 22:48:41 2014 +0200

WHATS_NEW: lvscan --cache, dmeventd RAID + lvmetad

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 88319bf..3595517 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.108 -
 =================================
+  Add lvscan --cache which re-scans constituents of a particular LV.
+  Make dmeventd's RAID plugin re-scan failed PVs when lvmetad is in use.
   Improve code sharing for lvconvert and lvcreate and pools (cache & thin).
   Improve lvconvert --merge validation.
   Improve lvconvert --splitsnapshot validation.


