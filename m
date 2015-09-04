From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  4 Sep 2015 18:54:08 +0000 (UTC)
Subject: master - WHATS_NEW_DM: fix histogram entries for 1.02.107
Message-ID: <20150904185408.213716031B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f868624f85059d935ec32a90f89a7d8266d7a6ca
Commit:        f868624f85059d935ec32a90f89a7d8266d7a6ca
Parent:        10ccbc5efaecdc93f40a07a61dad3f2cf8eff73f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Sep 4 19:53:10 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Sep 4 19:53:10 2015 +0100

WHATS_NEW_DM: fix histogram entries for 1.02.107

The histogram entries were under the wrong version (1.02.106). Fix
that and describe the library changes in more detail.
---
 WHATS_NEW_DM |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c40a023..a8db0ac 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,15 +1,20 @@
 Version 1.02.107 - 
 ===================================
   Parse thin-pool status with one single routine internally.
+  Add --histogram to select default histogram fields for list and report.
+  Add report fields for displaying latency histogram configuration and data.
+  Add dmstats --bounds to specify histogram boundaries for a new region.
+  Add dm_histogram_to_string() to format histogram data in string form.
+  Add public methods to libdm to access numerical histogram config and data.
+  Parse and store histogram data in dm_stats_list() and dm_stats_populate().
+  Add an argument to specify histogram bounds to dm_stats_create_region().
+  Add dm_histogram_bounds_from_{string,uint64_t}() to parse histogram bounds.
+  Add dm_histogram handle type to represent a latency histogram and its bounds.
   Fix devmapper.pc pkgconfig file to not reference non-existent rt.pc file.
   Reinstate dm_task_get_info at Base to libdevmapper exports. (1.02.106)
 
 Version 1.02.106 - 26th August 2015
 ===================================
-  Add basic report fields for displaying latency histogram data.
-  Add dmstats --histogram to specify histogram boundaries for a region.
-  Add public methods to libdm-stats to access numerical histogram data.
-  Add the ability to parse histogram data into numeric form to libdm-stats.
   Add 'precise' column to statistics reports.
   Add --precise switch to 'dmstats create' to request nanosecond counters.
   Add precise argument to dm_stats_create_region().


