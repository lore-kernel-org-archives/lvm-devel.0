From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 May 2017 15:29:44 -0400
Subject: master - man lvmraid: add more indirect conversion info
Message-ID: <201705221929.v4MJTiJm014577@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ca241964914fc151a9a2f370b1567b4a1ef5cb48
Commit:        ca241964914fc151a9a2f370b1567b4a1ef5cb48
Parent:        3877ef0e43a8dec17b35ede5824b561a13f6db46
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 22 14:28:04 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 22 14:28:24 2017 -0500

man lvmraid: add more indirect conversion info

---
 man/lvmraid.7_main |   53 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 2 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 6e0287a..c27f1fa 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -948,6 +948,50 @@ potential write/recovery performance reduction in raid6_ls_6 because of
 the dedicated parity device.  raid6_zr rotates data and parity blocks to
 avoid this.
 
+.B linear to striped
+
+To convert an LV from linear to striped:
+.br
+1. convert to raid1 with two images
+.br
+2. convert to raid5_n
+.br
+3. convert to raid5_n with five 128k stripes (reshape)
+.br
+4. convert raid5_n to striped
+
+The commands to perform the steps above are:
+.br
+1. lvconvert --type raid1 --mirrors 1 LV
+.br
+2. lvconvert --type raid5_n LV
+.br
+3. lvconvert --stripes 5 --stripesize 128k LV
+.br
+4. lvconvert --type striped LV
+
+The raid5_n type in step 2 is used because it has dedicated parity SubLVs
+at the end, and can be converted to striped directly.  The stripe size is
+increased in step 3 to add extra space for the conversion process.  This
+step grows the LV size by a factor of five.  After conversion, this extra
+space can be reduced (or used to grow the file system using the LV).
+
+Reversing these steps will convert a striped LV to linear.
+
+.B raid6 to striped
+
+To convert an LV from raid6_nr to striped:
+.br
+1. convert to raid6_n_6
+.br
+2. convert to striped
+
+The commands to perform the steps above are:
+.br
+1. lvconvert --type raid6_n_6 LV
+.br
+2. lvconvert --type striped LV
+
 
 .SS Examples
 
@@ -1316,7 +1360,7 @@ In case the RaidLV should be converted to striped:
 .nf
 # lvconvert --type striped vg/lv
   Unable to convert LV vg/lv from raid6_nr to striped.
-  Converting vg/lv from raid6_nr is directly possible to the \
+  Converting vg/lv from raid6_nr is directly possible to the \\
   following layouts:
     raid6_nc
     raid6_zr
@@ -1620,7 +1664,9 @@ RAID6 last parity devices
 .br
 \[bu]
 Fixed dedicated last devices (P-Syndrome N-1 and Q-Syndrome N)
+.RS 2
 with striped data used for striped/raid0 conversions
+.RE
 .br
 \[bu]
 Used for RAID Takeover
@@ -1631,7 +1677,10 @@ raid6_{ls,rs,la,ra}_6
 RAID6 last parity device
 .br
 \[bu]
-Dedicated last parity device used for conversions from/to raid5_{ls,rs,la,ra}
+Dedicated last parity device used for conversions from/to
+.RS 2
+raid5_{ls,rs,la,ra}
+.RE
 
 raid6_ls_6
 .br


