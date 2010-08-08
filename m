From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:35 +0200
Subject: [PATCH 23/25] Replicator: man page update for lvchange
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <45a4766e3ae5e5caaf00f9097f6962122b2e9480.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update lvchange man page to cover basic command usage.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 man/lvchange.8.in |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index e269802..3003442 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -7,6 +7,11 @@ lvchange \- change attributes of a logical volume
 [\-A|\-\-autobackup y|n] [\-a|\-\-available y|n|ey|en|ly|ln]
 [\-\-alloc AllocationPolicy]
 [\-C|\-\-contiguous y|n] [\-d|\-\-debug] [\-\-deltag Tag]
+[[\-\-site Site]
+[\-\-sitepolicy [sync|warn|stall|drop|fail]
+{[\-\-fallbehindios IOS] |
+[\-\-fallbehindsize Size[bBsSkKmMgGtTpPeE]] |
+[\-\-fallbehindtimeout [{[hh:mm:]|[mm:]}]ss]}]
 [\-\-resync]
 [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure]
@@ -112,10 +117,36 @@ If the logical volume is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong or if you're doing clustering 
 manually without a clustered lock manager.
+.TP
+.I \-\-fallbehindios
+How many pending io operations are allowed.
+Cannot be mixed with --fallbehindsize or --fallbehindtimeout.
+.TP
+.I \-\-fallbehindsize
+How many pending data are allowed.
+Cannot be mixed with --fallbehindios or --fallbehindtimeout.
+.TP
+.I \-\-fallbehindtimeout
+How much time of outstanding data are allowed.
+Cannot be mixed with --fallbehindios or --fallbehindsize.
+.TP
+.I \-\-sitepolicy
+Selects replication policy. Default is Warn.
+Use sync for synchronous policy. Warn,Stall,Drop,Fail are asynchronous policies.
+Warn issues warning when site is switched to sync log.
+Stall stalls replicator until remote site is back in range.
+Drop drops whole site, if it gets too behind.
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
1.7.2.1


