From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 29 Jun 2010 18:26:12 +0200
Subject: [PATCH 12/12] Replicator: man pages for lvchange.8
In-Reply-To: <cover.1277828149.git.zkabelac@redhat.com>
References: <cover.1277828149.git.zkabelac@redhat.com>
Message-ID: <6c750b86c5c5d51afc6f316e0123b5966db24f14.1277828149.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 man/lvchange.8.in |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index e269802..33196c9 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -7,6 +7,12 @@ lvchange \- change attributes of a logical volume
 [\-A|\-\-autobackup y|n] [\-a|\-\-available y|n|ey|en|ly|ln]
 [\-\-alloc AllocationPolicy]
 [\-C|\-\-contiguous y|n] [\-d|\-\-debug] [\-\-deltag Tag]
+[[\-\-site Site]
+{[\-\-fallbehinddata Size[bBsSkKmMgGtTpPeE]] |
+[\-\-fallbehindios  IOS] |
+[\-\-fallbehindtimeout sec]}
+[\-\-sitemode [sync|warn|stall|drop|fail]
+[\-\-remotevg RemoteVolumeGroupName]]
 [\-\-resync]
 [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure]
@@ -112,10 +118,41 @@ If the logical volume is active, reload its metadata.
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
+.I \-\-remotevg
+Selects remote volume group for remote site that contains logical volumes
+with same names for replication as the volume group for site. Local site
+for replicator is assumed if remotevolumegroup is not specified.
+.TP
 .SH Examples
 "lvchange -pr vg00/lvol1" changes the permission on 
 volume lvol1 in volume group vg00 to be read-only.
 
+"lvchange --site Berlin -ay vg00/L1"
+marks site Berlin for LV vg00/L1 as active.
+
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvcreate (8),
-- 
1.7.1


