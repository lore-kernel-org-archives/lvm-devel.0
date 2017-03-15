From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Mar 2017 12:31:06 -0400
Subject: master - man: remove blank lines in included files
Message-ID: <201703151631.v2FGV6WO024400@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=60eb74a27ad91112d9a3d0409286e1de2789418f
Commit:        60eb74a27ad91112d9a3d0409286e1de2789418f
Parent:        7e9bc7786538663f0079709f861d4deb873baaa2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 15 11:30:34 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 15 11:30:34 2017 -0500

man: remove blank lines in included files

---
 man/lvchange.8_end  |    1 -
 man/lvconvert.8_end |    3 ---
 man/lvcreate.8_des  |    1 -
 man/lvcreate.8_end  |    1 -
 man/lvextend.8_end  |    2 --
 5 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/man/lvchange.8_end b/man/lvchange.8_end
index 7134e46..0ae1cce 100644
--- a/man/lvchange.8_end
+++ b/man/lvchange.8_end
@@ -3,4 +3,3 @@
 Change LV permission to read-only:
 .sp
 .B lvchange \-pr vg00/lvol1
-
diff --git a/man/lvconvert.8_end b/man/lvconvert.8_end
index 5a3d475..bd17434 100644
--- a/man/lvconvert.8_end
+++ b/man/lvconvert.8_end
@@ -1,5 +1,4 @@
 .SH NOTES
-
 This previous command syntax would perform two different operations:
 .br
 \fBlvconvert --thinpool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
@@ -20,7 +19,6 @@ But, if LV1 was already a cache pool, the command would swap
 the current metadata LV with LV2 (for repair purposes.)
 
 .SH EXAMPLES
-
 Convert a linear LV to a two-way mirror LV.
 .br
 .B lvconvert \-\-type mirror \-\-mirrors 1 vg/lvol1
@@ -113,4 +111,3 @@ Detach and keep the cache pool from a cache LV.
 Detach and remove the cache pool from a cache LV.
 .br
 .B lvconvert \-\-uncache vg/lvol1
-
diff --git a/man/lvcreate.8_des b/man/lvcreate.8_des
index 2f5c5c1..42f4213 100644
--- a/man/lvcreate.8_des
+++ b/man/lvcreate.8_des
@@ -25,7 +25,6 @@ Thin LVs are thinly provisioned from a thin pool, and are created with a
 virtual size rather than a physical size. A cache LV is the combination of
 a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
-
 .SS Usage notes
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
 with \fB--extents\fP \fINumber\fP.  See both descriptions
diff --git a/man/lvcreate.8_end b/man/lvcreate.8_end
index 74ae599..b4ebd2d 100644
--- a/man/lvcreate.8_end
+++ b/man/lvcreate.8_end
@@ -95,4 +95,3 @@ then combining the new origin LV with an existing cache pool.
 .RS
 .B \-L 100G \-n mylv vg00 /dev/slow1
 .RE
-
diff --git a/man/lvextend.8_end b/man/lvextend.8_end
index 6d197de..aebe6d8 100644
--- a/man/lvextend.8_end
+++ b/man/lvextend.8_end
@@ -1,5 +1,4 @@
 .SH EXAMPLES
-
 Extend the size of an LV by 54MiB, using a specific PV.
 .br
 .B lvextend \-L +54 vg01/lvol10 /dev/sdk3
@@ -13,4 +12,3 @@ space on PV /dev/sdk3. This is equivalent to specifying
 Extend an LV by 16MiB using specific physical extents.
 .br
 .B lvextend \-L+16m vg01/lvol01 /dev/sda:8\-9 /dev/sdb:8\-9
-


