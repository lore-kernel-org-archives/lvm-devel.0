From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jan 2019 16:41:01 -0500
Subject: master - vdo: add some basic example
Message-ID: <201901282141.x0SLf18K002483@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb90606c8338617d7ae3d13b5c5e381def030ff7
Commit:        cb90606c8338617d7ae3d13b5c5e381def030ff7
Parent:        59b87cf7d67613d82e8dff7eb10f3c6ceaea0124
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 28 21:39:40 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 28 22:39:10 2019 +0100

vdo: add some basic example

---
 man/lvcreate.8_end |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/man/lvcreate.8_end b/man/lvcreate.8_end
index 2770f62..19e2461 100644
--- a/man/lvcreate.8_end
+++ b/man/lvcreate.8_end
@@ -64,6 +64,10 @@ to the first image).
 .br
 .B lvcreate --type raid10 -L 5G -i 2 -m 1 -n mylv vg00
 
+Create a 1TiB thin LV mythin, with 256GiB thinpool tpool0 in vg00.
+.br
+.B lvcreate --T --size 256G --name mythin vg00/tpool0
+
 Create a 1TiB thin LV, first creating a new thin pool for it, where
 the thin pool has 100MiB of space, uses 2 stripes, has a 64KiB stripe
 size, and 256KiB chunk size.
@@ -95,3 +99,7 @@ then combining the new origin LV with an existing cache pool.
 .RS
 .B -L 100G -n mylv vg00 /dev/slow1
 .RE
+
+Create a VDO LV vdo0 with VDOPoolLV size of 10GiB and name vpool1.
+.br
+.B lvcreate --vdo --size 10G --name vdo0 vg00/vpool1


