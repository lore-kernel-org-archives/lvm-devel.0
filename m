From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Jul 2014 07:50:06 +0000 (UTC)
Subject: master - conf: command_profile_template: global/binary_values_as_numeric -> report/binary_values_as_numeric
Message-ID: <20140710075006.CA68D616E1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fafd10d564151b91e814f6be3e735bdf0b7d33dd
Commit:        fafd10d564151b91e814f6be3e735bdf0b7d33dd
Parent:        a4e798bd304253b91b906ca77988b11576685d72
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 10 09:48:45 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 10 09:48:45 2014 +0200

conf: command_profile_template: global/binary_values_as_numeric -> report/binary_values_as_numeric

---
 conf/command_profile_template.profile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/conf/command_profile_template.profile.in b/conf/command_profile_template.profile.in
index 592a69d..7401aa5 100644
--- a/conf/command_profile_template.profile.in
+++ b/conf/command_profile_template.profile.in
@@ -13,7 +13,6 @@
 #
 global {
 	units="h"
-	report_binary_values_as_numeric=0
 	si_unit_consistency=1
 	suffix=1
 	lvdisplay_shows_full_device_path=0
@@ -26,6 +25,7 @@ report {
 	prefixes=0
 	quoted=1
 	colums_as_rows=0
+	binary_values_as_numeric=0
 	devtypes_sort="devtype_name"
 	devtypes_cols="devtype_name,devtype_max_partitions,devtype_description"
 	devtypes_cols_verbose="devtype_name,devtype_max_partitions,devtype_description"


