From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:55 +0200
Subject: [PATCH 21/22] Replicator: man page update for lvchange
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <cdf7ac7abd17859fc727eb46e63f741ca7f1e7ae.1278505885.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update lvchange man page to cover basic usability commands.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 man/lvchange.8.in |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index e269802..6899613 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -7,6 +7,11 @@ lvchange \- change attributes of a logical volume
 [\-A|\-\-autobackup y|n] [\-a|\-\-available y|n|ey|en|ly|ln]
 [\-\-alloc AllocationPolicy]
 [\-C|\-\-contiguous y|n] [\-d|\-\-debug] [\-\-deltag Tag]
+[[\-\-site Site]
+[\-\-sitemode [sync|warn|stall|drop|fail]
+{[\-\-fallbehinddata Size[bBsSkKmMgGtTpPeE]] |
+[\-\-fallbehindios  IOS] |
+[\-\-fallbehindtimeout sec]}]
 [\-\-resync]
 [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure]
@@ -112,10 +117,36 @@ If the logical volume is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong or if you're doing clustering 
 manually without a clustered lock manager.
+.TP
+.I \-\-fallbehinddata
+How many data could get replicator behind. Cannot be mixed
+with --fallbehindios or --fallbehindtimeout.
+.TP
+.I \-\-fallbehindios
+How many io operation could be queued in replicator backing store device.
+Cannot be mixed with --fallbehinddata or --fallbehindtimeout.
+.TP
+.I \-\-fallbehindtimeout
+How many seconds could be replicator behind actual data. Cannot be mixed
+with --fallbehinddata or --fallbehindios.
+.TP
+.I \-\-sitemode
+Select replication mode. Default is Warn.
+Sync is synchronous mode. Warn,Stall,Drop,Fail are asynchronous modes.
+Warn issues warning when remote site is switched to sync log.
+Stall stalls replicator until remote site is back in range.
+Drop drops whole remote site, if it get too behind.
+Fail whole replicator fails is remote sites gets too behind.
+Local site works usually in stall mode. There is no synclog for local
+replicated volumes.
+.TP
 .SH Examples
 "lvchange -pr vg00/lvol1" changes the permission on 
 volume lvol1 in volume group vg00 to be read-only.
 
+"lvchange --site Berlin -ay vg00/L1"
+marks the local site Berlin for LV "vg00/L1" as active.
+
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvcreate (8),
-- 
1.7.1.1


