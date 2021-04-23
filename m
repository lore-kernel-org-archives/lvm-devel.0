From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:09 +0000 (GMT)
Subject: main - man: add some resizing examples
Message-ID: <20210423210609.EC0C3393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=348c46c8fcc285b1c7495a3792f2c3b1c2939e8e
Commit:        348c46c8fcc285b1c7495a3792f2c3b1c2939e8e
Parent:        a21028dea71464f93cd1c0836aee63ebfc3add10
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 23 12:53:14 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

man: add some resizing examples

Add some examples with -l% usage.
---
 man/lvextend.8_end | 6 ++++++
 man/lvresize.8_end | 6 +++++-
 man/see_also.end   | 1 +
 3 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/man/lvextend.8_end b/man/lvextend.8_end
index 3cffe1d25..4b25c2c3b 100644
--- a/man/lvextend.8_end
+++ b/man/lvextend.8_end
@@ -14,3 +14,9 @@ space on PV /dev/sdk3. This is equivalent to specifying
 Extend an LV by 16MiB using specific physical extents.
 .br
 .B lvextend -L+16m vg01/lvol01 /dev/sda:8-9 /dev/sdb:8-9
+.P
+Extend an LV to use all remaining free space in volume group
+and all resize its filesystem with
+.BR fsadm (8).
+.br
+.B lvextend -l+100%FREE -r vg01/lvol01
diff --git a/man/lvresize.8_end b/man/lvresize.8_end
index b69d6acd3..d16248ce1 100644
--- a/man/lvresize.8_end
+++ b/man/lvresize.8_end
@@ -1,6 +1,10 @@
 .
 .SH EXAMPLES
 .
-Extend an LV by 16MB using specific physical extents:
+Extend an LV by 16MB using specific physical extents.
 .br
 .B lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1
+.P
+Resize an LV to use 50% of the size volume group.
+.br
+.B lvresize -l50%VG vg1/lv1
diff --git a/man/see_also.end b/man/see_also.end
index e740ce588..cf7834052 100644
--- a/man/see_also.end
+++ b/man/see_also.end
@@ -63,6 +63,7 @@
 .BR lvmlockctl (8),
 .BR cmirrord (8),
 .BR lvmdbusd (8),
+.BR fsadm (8),
 .P
 .BR lvmsystemid (7),
 .BR lvmreport (7),


