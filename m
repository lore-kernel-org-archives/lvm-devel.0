From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 12:56:36 +0000 (UTC)
Subject: master - WHATS_NEW_DM: recent commits (stats field split and timestamp headers)
Message-ID: <20150814125636.932D660F79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d5b618d52f9f26537f8044bd4e6b139032c46c1
Commit:        4d5b618d52f9f26537f8044bd4e6b139032c46c1
Parent:        e6724f0303b8dee0806ac799f0035d9f928441fc
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 14 13:20:20 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 13:43:12 2015 +0100

WHATS_NEW_DM: recent commits (stats field split and timestamp headers)

---
 WHATS_NEW_DM |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f3b62b1..8e816a0 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,9 @@
 Version 1.02.105 - 
 ===================================
+  Fix 'stats list -o all' segfault
+  Separate statistics fields from region information fields
+  Add interval and interval_ns fields to DR_STATS reports.
+  Do not include internal glibc headers in libdm-timestamp.c (1.02.104)
   Exit immediately if no device is supplied to dmsetup wipe_table.
   Suppress dmsetup report headings when no data is output. (1.02.104)
   Adjust dmsetup usage/help output selection to match command invoked.


