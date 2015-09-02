From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  2 Sep 2015 20:03:30 +0000 (UTC)
Subject: master - man: update dmstats.8.in examples
Message-ID: <20150902200330.AD3956100C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d31c4e0bc12fb673d4b30ba8846eec8e27ae6276
Commit:        d31c4e0bc12fb673d4b30ba8846eec8e27ae6276
Parent:        031cd2bb0dc436619b1e186512a024ea095c2324
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Sep 2 12:19:13 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Sep 2 21:03:03 2015 +0100

man: update dmstats.8.in examples

Make sure that correct 'dmstats create' messages are shown for all
examples and fix LV examples to use correct dmsetup output name
format (vg/lv -> vg-lv).
---
 man/dmstats.8.in |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index eb8f400..69ba2a3 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -779,17 +779,17 @@ Create a whole-device region with 8 areas on every device
 .br
 # dmstats create --areas 8
 .br
-vg00/lvol1: Created new region with 8 area(s) as region ID 0
+vg00-lvol1: Created new region with 8 area(s) as region ID 0
 .br
-vg00/lvol2: Created new region with 8 area(s) as region ID 0
+vg00-lvol2: Created new region with 8 area(s) as region ID 0
 .br
-vg00/lvol3: Created new region with 8 area(s) as region ID 0
+vg00-lvol3: Created new region with 8 area(s) as region ID 0
 .br
-vg01/lvol0: Created new region with 8 area(s) as region ID 2
+vg01-lvol0: Created new region with 8 area(s) as region ID 2
 .br
-vg01/lvol1: Created new region with 8 area(s) as region ID 0
+vg01-lvol1: Created new region with 8 area(s) as region ID 0
 .br
-vg00/lvol2: Created new region with 8 area(s) as region ID 1
+vg00-lvol2: Created new region with 8 area(s) as region ID 1
 .br
 .br
 
@@ -806,7 +806,7 @@ using dmsetup
 .br
 # dmsetup stats create --areasize 10G vg00/lvol1
 .br
-vg00/lvol1: Created new region with 5 area(s) as region ID 1
+vg00-lvol1: Created new region with 5 area(s) as region ID 1
 .br
 .br
 
@@ -814,7 +814,7 @@ Create a 1GiB region with 16 areas at the start of vg00/lvol1
 .br
 # dmstats create --start 0 --len 1G --areas=16 vg00/lvol1
 .br
-vg00/lvol1: Created new region with 16 area(s) as region ID 0
+vg00-lvol1: Created new region with 16 area(s) as region ID 0
 .br
 .br
 
@@ -854,11 +854,11 @@ Create one region for reach target contained in device vg00/lvol1
 .br
 # dmstats create --segments vg00/lvol1
 .br
-Created new region with 1 area(s) as region ID 0
+vg00-lvol1: Created new region with 1 area(s) as region ID 0
 .br
-Created new region with 1 area(s) as region ID 1
+vg00-lvol1: Created new region with 1 area(s) as region ID 1
 .br
-Created new region with 1 area(s) as region ID 2
+vg00-lvol1: Created new region with 1 area(s) as region ID 2
 .br
 .br
 


