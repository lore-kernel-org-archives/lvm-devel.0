From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 20 Jan 2015 19:29:09 +0000 (UTC)
Subject: master - lvmthin: include errorwhenfull
Message-ID: <20150120192909.A98ED6121D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e8f362c9eaae7bbcf69fd779d8c441f7de9042a
Commit:        5e8f362c9eaae7bbcf69fd779d8c441f7de9042a
Parent:        a164d603d386c5daed06b46316ef3c001807dff9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 20 10:45:47 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 20 13:28:34 2015 -0600

lvmthin: include errorwhenfull

and don't display the size of pmspare to avoid setting an
expectation of a specific size.
---
 man/lvmthin.7.in |   51 +++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 45 insertions(+), 6 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 84a3138..b2db5a7 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -398,10 +398,10 @@ explicitly.
 # lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
 
 # lvs \-a
-  [lvol0_pmspare] vg          ewi-------  10.00g
-  pool0           vg          twi---tz--  10.00g
-  [pool0_tdata]   vg          Twi-------  10.00g
-  [pool0_tmeta]   vg          ewi-------   1.00g
+  [lvol0_pmspare] vg          ewi-------
+  pool0           vg          twi---tz--
+  [pool0_tdata]   vg          Twi-------
+  [pool0_tmeta]   vg          ewi-------
 .fi
 
 The "Metadata check and repair" section describes the use of
@@ -715,8 +715,47 @@ For a 1G pool, using 700M will trigger a resize to 1.2G. When the usage exceeds
 
 \&
 
-If thin pool data space is exhausted, writes to thin LVs will be queued
-until the the data space is extended.  Reading is still possible.
+When properly managed, thin pool data space should be extended before it
+is exhausted (see previous section).  But, if thin pool data space is
+exhausted, the thin pool behavior is configurable with the --errorwhenfull
+y|n option to lvcreate or lvchange.  The errorwhenfull setting applies
+only to writes; reading thin LVs can continue even when data space is
+exhausted.
+
+Command to change the handling of data space exhaustion of an existing
+thin pool LV:
+
+.B lvchange --errorwhenfull {y|n} VG/ThinPoolLV
+
+The current setting can be displayed with the lvs -o+error_when_full
+command.
+
+.B errorwhenfull n
+
+This is the default.  Writes to thin LVs are accepted and queued, with the
+expectation that pool data space will be extended soon.  Once data space
+is extended, the queued writes will be processed, and the thin pool will
+return to normal operation.
+
+While waiting to be extended, the thin pool will queue writes for up to 60
+seconds.  If data space has not been extended after this time, the queued
+writes will return an error to the caller, e.g. the file system.  This can
+result in file system corruption that may require fsck to repair.
+
+The 60 second timeout can be changed or disabled with the dm\-thin\-pool
+kernel module option
+.B no_space_timeout.
+This option sets the number of seconds that thin pools will queue writes.
+If set to 0, writes will not time out.  Disabling timeouts may result in
+the system exhausting memory if too many writes are queued.
+
+.B errorwhenfull y
+
+Writes to thin LVs immediately return an error, and no writes are queued.
+In the case of a file system, this can result in corruption that may
+require fsck to repair (the specific consequences depend on the thin LV
+user.)
+
 
 When data space is exhausted, the lvs command displays 100 under Data% for
 the thin pool LV:


