From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 12 Apr 2017 13:42:17 -0400
Subject: master - WHATS_NEW: add recent RAID entries
Message-ID: <201704121742.v3CHgHkd030969@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19e6c338d32a081a94fb210785f0443406d2ff66
Commit:        19e6c338d32a081a94fb210785f0443406d2ff66
Parent:        51a31dbd79e6fd9dc289250f875badd9afbff428
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Apr 12 19:41:55 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Apr 12 19:41:55 2017 +0200

WHATS_NEW: add recent RAID entries

---
 WHATS_NEW |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 57e01d4..85636e8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,10 @@
 Version 2.02.170 - 
 ==================================
+  Better message on lvconvert --regionsize
+  Allow valid lvconvert --regionsize change
+  Add raid10 alias raid10_near
+  Handle insufficient PVs on lvconvert takeover
+  Fix SIGINT blocking to prevent corrupted metadata
   Fix systemd unit existence check for lvmconf --services --startstopservices.
   Check and use PATH_MAX buffers when creating vgrename device paths.
 


