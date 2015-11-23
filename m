From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 23 Nov 2015 17:58:16 +0000 (UTC)
Subject: master - man lvmcache: include chunk size
Message-ID: <20151123175816.41AE56067A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe64d3a2e27cedd7973d0a01360796089596b20b
Commit:        fe64d3a2e27cedd7973d0a01360796089596b20b
Parent:        c026846739eeea4432b75bbe8d577944f0f6b55b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 23 11:57:41 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 23 11:57:41 2015 -0600

man lvmcache: include chunk size

---
 man/lvmcache.7.in |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 44709d1..45bb5b1 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -301,6 +301,35 @@ defines the default cache policy.
 defines the default cache settings.
 
 
+.SS Chunk size
+
+\&
+
+The size of data blocks managed by a cache pool can be specified with the
+\-\-chunksize option when the cache LV is created.  The default unit
+is KiB. The value must be a multiple of 32KiB between 32KiB and 1GiB.
+
+Using a chunk size that is too large can result in wasteful use of the
+cache, where small reads and writes can cause large sections of an LV to
+be mapped into the cache.  However, choosing a chunk size that is too
+small can result in more overhead trying to manage the numerous chunks
+that become mapped into the cache.  Overhead can include both excessive
+CPU time searching for chunks, and excessive memory tracking chunks.
+
+Command to display the cache pool LV chunk size:
+.br
+.B lvs \-o+chunksize VG/CacheLV
+
+.BR lvm.conf (5)
+.B cache_pool_chunk_size
+.br
+controls the default chunk size used when creating a cache LV.
+
+The default value is shown by:
+.br
+.B lvmconfig \-\-type default allocation/cache_pool_chunk_size
+
+
 .SS Spare metadata LV
 
 \&


