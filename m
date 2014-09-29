From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 29 Sep 2014 17:28:41 +0000 (UTC)
Subject: master - man: lvmthin remove unnecessary fixme
Message-ID: <20140929172841.71B8060EF4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f3c11b39acc4252d6d40ae040319f66f9060a75
Commit:        9f3c11b39acc4252d6d40ae040319f66f9060a75
Parent:        9646c3359f89840dd05560d0adfab99f337d81f3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 29 12:28:00 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 29 12:28:00 2014 -0500

man: lvmthin remove unnecessary fixme

The existing method for single step thin-pool + thin creation
makes sense.
---
 man/lvmthin.7.in |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 30a31d1..af9669d 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -1007,9 +1007,6 @@ and creates a thin LV in the new pool.
 .B \-n ThinLV \-\-thinpool VG/ThinPoolLV
 .RE
 
-./" FIXME: make this work
-./" lvcreate \-\-type thin\-pool \-V VirtualSize \-L LargeSize \-n ThinLV VG/ThinPoolLV
-
 Equivalent to:
 .br
 .B lvcreate \-\-type thin\-pool \-L LargeSize VG/ThinPoolLV
@@ -1021,9 +1018,6 @@ Equivalent to:
 .nf
 # lvcreate \-L8M \-V2G \-n thin1 \-\-thinpool vg/pool0
 
-./" FIXME: change to
-./" lvcreate \-\-type thin\-pool \-L8M \-V2G \-n thin1 vg/pool0
-
 # lvs \-a
   pool0           vg          twi-a-tz--   8.00m
   [pool0_tdata]   vg          Twi-ao----   8.00m


