From: David Teigland <teigland@sourceware.org>
Date: Mon, 21 Feb 2022 17:36:31 +0000 (GMT)
Subject: main - man lvmcache: mention writecache memory usage
Message-ID: <20220221173631.21232385DC22@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6144dac897728a4857294d70645df8ed7a5ff11f
Commit:        6144dac897728a4857294d70645df8ed7a5ff11f
Parent:        96c99d647ef783abcd26a1f3f63f12e033195633
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 21 11:35:58 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 21 11:35:58 2022 -0600

man lvmcache: mention writecache memory usage

---
 man/lvmcache.7_main | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index dddd33cfa..ce440bf49 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -240,6 +240,18 @@ The writecache block size should be chosen to match the xfs sectsz value.
 It is also possible to specify a sector size of 4096 to mkfs.xfs when
 creating the file system.  In this case the writecache block size of 4096
 can be used.
+.P
+.SS dm-writecache memory usage
+.P
+The amount of main system memory used by dm-writecache can be a factor
+when selecting the writecache cachevol size and the writecache block size.
+.P
+.IP \[bu] 2
+writecache block size 4096: each 100 GiB of writecache cachevol uses
+slighly over 2 GiB of system memory.
+.IP \[bu] 2
+writecache block size 512: each 100 GiB of writecache cachevol uses
+a little over 16 GiB of system memory.
 .
 .SS dm-writecache settings
 .


