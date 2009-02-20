From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 20 Feb 2009 09:46:32 -0500 (EST)
Subject: [PATCH]: fix warning when compiling lvm as 64-bit binary on Sparc
Message-ID: <Pine.LNX.4.64.0902200943450.1519@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

On 64-bit big endiagn machines, '%lx' argument is given and unsigned long 
long value is supplied as and argument. Gcc warns about it.

Mikulas

---

Suppress warning on 64-bit big-endian computers (Sparc 64).

xlate64 produces unsigned long long type, but PRIu64 is defined
to accept argument unsigned long type (on 64-bit machines).

On existing machines, both types have the same size, so it works,
but it is still wrong and produces a warning.

Fix it by using a cast to uint64_t --- according to the standard,
PRIu64 argument matches type uint64_t.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 lib/label/label.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: LVM2.2.02.44/lib/label/label.c
===================================================================
--- LVM2.2.02.44.orig/lib/label/label.c	2009-02-20 14:51:25.000000000 +0100
+++ LVM2.2.02.44/lib/label/label.c	2009-02-20 14:51:59.000000000 +0100
@@ -138,7 +138,7 @@ static struct labeller *_find_labeller(s
 				log_info("%s: Label for sector %" PRIu64
 					 " found at sector %" PRIu64
 					 " - ignoring", dev_name(dev),
-					 xlate64(lh->sector_xl),
+					 (uint64_t)xlate64(lh->sector_xl),
 					 sector + scan_sector);
 				continue;
 			}


