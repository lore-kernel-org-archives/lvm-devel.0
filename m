From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:27:03 +0000 (UTC)
Subject: master - doc: mention --segments grouping in dmstats.8.in
Message-ID: <20160708182703.C9483610EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6cb0c7bb5c41c4fa2bdc1604e86154efa946c600
Commit:        6cb0c7bb5c41c4fa2bdc1604e86154efa946c600
Parent:        bd1f4987eb954705e6ba8997ac37de025074e539
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 7 15:10:07 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 17:27:52 2016 +0100

doc: mention --segments grouping in dmstats.8.in

---
 man/dmstats.8.in |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index def83ca..96aca01 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -460,9 +460,13 @@ optional suffix selects units of:
 .HP
 .BR \-\-segments
 .br
-Create a new statistics region for each target contained in the target
-device. This causes a separate region to be allocated for each segment
-of the device.
+When used with \fBcreate\fP, create a new statistics region for each
+target contained in the given device(s). This causes a separate region
+to be allocated for each segment of the device.
+
+The newly created regions are automatically placed into a group unless
+the \fB\-\-nogroup\fP option is given. When grouping is enabled a group
+alias may be specified using the \fB\-\-alias\fP option.
 .
 .HP
 .BR \-\-statstype


