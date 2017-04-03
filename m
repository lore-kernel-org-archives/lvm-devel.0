From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Apr 2017 16:50:08 -0400
Subject: master - commands: ignore partial option in most cases
Message-ID: <201704032050.v33Ko8gb026550@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=162272e5a5ad5249c30f024c9dc69f5a1ece8fea
Commit:        162272e5a5ad5249c30f024c9dc69f5a1ece8fea
Parent:        51ff707ac859b6ab1ba1bc6cc8d9ea154632f2f7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 3 14:39:35 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 3 15:43:04 2017 -0500

commands: ignore partial option in most cases

These days --partial is only used with activation in
lvchange/vgchange.  It probably had another meaning
at some point in history which is no longer used,
so ignore it in those cases.

When included in the OO list, the option is advertised in
help/man output, implying it is meaningful to the command,
when in fact the command never uses it.
The IO list means the option won't cause an error if it's
used, but is not displayed as an valid option for the command.
If the option is not included in either OO or IO lists,
using the option would cause a command error, which would cause
problems for anyone is using the option for historical reasons.
---
 tools/command-lines.in |   24 +++++++++++++++++-------
 1 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 9f0fc79..a83fb43 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -196,7 +196,7 @@ OO_ALL: --commandprofile String, --config String, --debug,
 OO_REPORT: --aligned, --all, --binary, --configreport ConfigReport, --foreign,
 --ignorelockingfailure, --ignoreskippedcluster, --logonly,
 --nameprefixes, --noheadings, --nolocking, --nosuffix,
---options String, --partial, --readonly, --reportformat ReportFmt, --rows,
+--options String, --readonly, --reportformat ReportFmt, --rows,
 --select String, --separator String, --shared, --sort String,
 --trustcache, --unbuffered, --units Units, --unquoted
 
@@ -1177,10 +1177,11 @@ lvdisplay
 OO: --aligned, --all, --binary, --colon, --columns,
 --configreport ConfigReport, --foreign, --history, --ignorelockingfailure,
 --ignoreskippedcluster, --logonly, --maps, --noheadings,
---nosuffix, --options String, --sort String, --partial, --readonly,
+--nosuffix, --options String, --sort String, --readonly,
 --reportformat ReportFmt, --segments, --select String, --separator String,
 --shared, --unbuffered, --units Units
 OP: VG|LV|Tag ...
+IO: --partial
 ID: lvdisplay_general
 
 ---
@@ -1294,19 +1295,22 @@ DESC: Resize a pool metadata SubLV by a specified size.
 lvs
 OO: --history, --segments, OO_REPORT
 OP: VG|LV|Tag ...
+IO: --partial
 ID: lvs_general
 
 ---
 
 lvscan
-OO: --all, --blockdevice, --ignorelockingfailure, --partial,
+OO: --all, --blockdevice, --ignorelockingfailure,
 --readonly, --reportformat ReportFmt
+IO: --partial
 ID: lvscan_general
 
 lvscan --cache_long
-OO: --blockdevice, --ignorelockingfailure, --partial,
+OO: --blockdevice, --ignorelockingfailure,
 --readonly, --reportformat ReportFmt
 OP: LV ...
+IO: --partial
 ID: lvscan_cache
 
 ---
@@ -1390,6 +1394,7 @@ ID: pvremove_general
 pvs
 OO: --segments, OO_REPORT
 OP: PV|Tag ...
+IO: --partial
 ID: pvs_general
 
 ---
@@ -1410,9 +1415,10 @@ DESC: Populate the lvmetad cache by scanning PVs.
 ---
 
 vgcfgbackup
-OO: --file String, --foreign, --ignorelockingfailure, --partial, --readonly,
+OO: --file String, --foreign, --ignorelockingfailure, --readonly,
 --reportformat ReportFmt
 OP: VG ...
+IO: --partial
 ID: vgcfgbackup_general
 
 ---
@@ -1538,9 +1544,10 @@ vgdisplay
 OO: --activevolumegroups, --aligned, --binary, --colon, --columns,
 --configreport ConfigReport, --foreign, --ignorelockingfailure,
 --ignoreskippedcluster, --logonly, --noheadings, --nosuffix,
---options String, --partial, --readonly, --reportformat ReportFmt, --select String,
+--options String, --readonly, --reportformat ReportFmt, --select String,
 --shared, --short, --separator String, --sort String, --unbuffered, --units Units
 OP: VG|Tag ...
+IO: --partial
 ID: vgdisplay_general
 
 ---
@@ -1642,13 +1649,15 @@ DESC: Rename a VG by specifying the VG UUID.
 vgs
 OO: OO_REPORT
 OP: VG|Tag ...
+IO: --partial
 ID: vgs_general
 
 ---
 
 vgscan
 OO: --cache_long, --ignorelockingfailure, --mknodes, --notifydbus,
---partial, --reportformat ReportFmt
+--reportformat ReportFmt
+IO: --partial
 ID: vgscan_general
 
 ---
@@ -1695,6 +1704,7 @@ ID: devtypes_general
 fullreport
 OO: OO_REPORT
 OP: VG ...
+IO: --partial
 ID: fullreport_general
 
 lastlog


