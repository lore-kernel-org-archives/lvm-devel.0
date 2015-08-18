From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 18 Aug 2015 13:41:16 +0000 (UTC)
Subject: master - man: update dmstats.8.in examples
Message-ID: <20150818134116.2832C60E37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc395067921fdd96c386e6d5b4ea613a39efea33
Commit:        bc395067921fdd96c386e6d5b4ea613a39efea33
Parent:        28b4fa3e270711e7f7ee45642b28a7c7127ea982
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Aug 16 19:30:16 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Aug 18 14:40:45 2015 +0100

man: update dmstats.8.in examples

---
 man/dmstats.8.in |   48 ++++++++++++++++++++++--------------------------
 1 files changed, 22 insertions(+), 26 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index a6b2ff5..5c5f41c 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -591,7 +591,7 @@ Create a whole-device region with one area on vg00/lvol1
 .br
 # dmstats create vg00/lvol1
 .br
-Created region: 0
+vg00/lvol1: Created new region with 1 area(s) as region ID 0
 .br
 .br
 
@@ -601,7 +601,7 @@ Create a 32M region 1G into device d0
 .br
 # dmstats create --start 1G --length 32M d0
 .br
-Created region: 2
+d0: Created new region with 1 area(s) as region ID 0
 .br
 
 
@@ -610,17 +610,17 @@ Create a whole-device region with 8 areas on every device
 .br
 # dmstats create --areas 8
 .br
-Created region: 0
+vg00/lvol1: Created new region with 8 area(s) as region ID 0
 .br
-Created region: 0
+vg00/lvol2: Created new region with 8 area(s) as region ID 0
 .br
-Created region: 0
+vg00/lvol3: Created new region with 8 area(s) as region ID 0
 .br
-Created region: 2
+vg01/lvol0: Created new region with 8 area(s) as region ID 2
 .br
-Created region: 0
+vg01/lvol1: Created new region with 8 area(s) as region ID 0
 .br
-Created region: 0
+vg00/lvol2: Created new region with 8 area(s) as region ID 1
 .br
 .br
 
@@ -637,7 +637,7 @@ using dmsetup
 .br
 # dmsetup stats create --areasize 10G vg00/lvol1
 .br
-Created region: 1
+vg00/lvol1: Created new region with 5 area(s) as region ID 1
 .br
 .br
 
@@ -645,7 +645,7 @@ Create a 1GiB region with 16 areas at the start of vg00/lvol1
 .br
 # dmstats create --start 0 --len 1G --areas=16 vg00/lvol1
 .br
-Created region: 2
+vg00/lvol1: Created new region with 16 area(s) as region ID 0
 .br
 .br
 
@@ -653,13 +653,13 @@ List the statistics regions registered on vg00/lvol1
 .br
 # dmstats list vg00/lvol1
 .br
-RegionID    RegStart    RegLen  AreaSize ProgramID AuxData
+Name             RgID  RStart RSize  #Areas ASize  ProgID
 .br
-0                  0 104857600  20971520 dmstats
+vg00-lvol1           0      0 61.00g      1 61.00g dmstats
 .br
-1                  0 104857600  20971520 dmstats
+vg00-lvol1           1 61.00g 19.20g      1 19.20g dmstats
 .br
-2                  0   2097152    131072 dmstats
+vg00-lvol1           2 80.20g  2.14g      1  2.14g dmstats
 .br
 .br
 
@@ -668,19 +668,15 @@ Display five statistics reports for vg00/lvol1 at an interval of one second
 .br
 # dmstats report --interval 1 --count 5 vg00/lvol1
 .br
-Name             RgID  ArID  RRqM/s   WRqM/s   R/s    W/s   RSz/s   WSz/s AvRqSz QSize SvcTm Util% AWait
+# dmstats report
 .br
-vg00-lvol1       0     0     0.00     0.00   8.00  0.00  48.00k     0  6.00k  0.00  5.50  4.40  6.62
+Name             RgID  ArID  AStart ASize  RRqM/s   WRqM/s   R/s   W/s    RSz/s WSz/s   AvRqSz  QSize Util%      AWait RdAWa WrAWa
 .br
-vg00-lvol1       0     1     0.00     0.00  22.00  0.00 624.00k     0 28.00k  0.00  5.23 11.50  5.36
+vg_hex-lv_home       0     0      0 61.00g     0.00     0.00  0.00 218.00     0   1.04m   4.50k  2.97      81.70 13.62  0.00 13.62
 .br
-vg00-lvol1       0     2     0.00     0.00 353.00  0.00   1.84m     0  5.00k  0.00  1.34 47.40  1.33
+vg_hex-lv_home       1     0 61.00g 19.20g     0.00     0.00  0.00   5.00     0 548.00k 109.50k  0.14      11.00 27.40  0.00 27.40
 .br
-vg00-lvol1       0     3     0.00     0.00  73.00  0.00 592.00k     0  8.00k  0.00  2.10 15.30  2.10
-.br
-vg00-lvol1       0     4     0.00     0.00   5.00  0.00  52.00k     0 10.00k  0.00  4.00  2.00  4.00
-.br
-[...]
+vg_hex-lv_home       2     0 80.20g  2.14g     0.00     0.00  0.00  14.00     0   1.15m  84.00k  0.39      18.70 27.71  0.00 27.71
 .br
 .br
 
@@ -689,11 +685,11 @@ Create one region for reach target contained in device vg00/lvol1
 .br
 # dmstats create --segments vg00/lvol1
 .br
-Created region: 0
+Created new region with 1 area(s) as region ID 0
 .br
-Created region: 1
+Created new region with 1 area(s) as region ID 1
 .br
-Created region: 2
+Created new region with 1 area(s) as region ID 2
 .br
 .br
 


