From: David Teigland <teigland@sourceware.org>
Date: Mon, 19 Aug 2019 15:10:09 -0400
Subject: stable-2.02 - man lvmthin: remove nonexistent topic
Message-ID: <201908191910.x7JJA9dI023422@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=881f49a7676aae2fd35acc390d9882a2e950932c
Commit:        881f49a7676aae2fd35acc390d9882a2e950932c
Parent:        474963573af2112467fcd6b17f42971e3178eaa8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 19 14:06:32 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 19 14:09:43 2019 -0500

man lvmthin: remove nonexistent topic

---
 man/lvmthin.7_main |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index 251ba12..27bad57 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -226,8 +226,6 @@ or vgchange to activate thin snapshots with the "k" attribute.
 
 .SH Thin Topics
 
-.B Alternate syntax for specifying type thin-pool
-.br
 .B Automatic pool metadata LV
 .br
 .B Specify devices for data and metadata LVs


