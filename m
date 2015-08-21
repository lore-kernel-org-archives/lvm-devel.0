From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Aug 2015 13:36:17 +0000 (UTC)
Subject: master - man: fix sqm typo
Message-ID: <20150821133617.D293760DC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c868609cff48597db50ac5bb98ecba0ecc828dbd
Commit:        c868609cff48597db50ac5bb98ecba0ecc828dbd
Parent:        e4b9ac46d74e2783d4a27ceffc49d7f97fe4409f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 21 11:06:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 21 15:35:45 2015 +0200

man: fix sqm typo

---
 man/lvconvert.8.in |    2 +-
 man/lvcreate.8.in  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 562de1e..c2ee2b2 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -228,7 +228,7 @@ For more information on cache pool LVs and cache LVs, see \fBlvmcache\fP(7).
 .TP
 .B \-\-cachepolicy \fIpolicy
 Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
-the cache policy. \fImq\fP is the basic policy name. \fIsqm\fP is more advanced
+the cache policy. \fImq\fP is the basic policy name. \fIsmq\fP is more advanced
 version available in newer kernels.
 .TP
 .BR \-\-cachepool " " \fICachePoolLV
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 5f922b4..ee10392 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -200,7 +200,7 @@ cache pool LV.
 .TP
 .B \-\-cachepolicy \fIpolicy
 Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
-the cache policy. \fImq\fP is the basic policy name. \fIsqm\fP is more advanced
+the cache policy. \fImq\fP is the basic policy name. \fIsmq\fP is more advanced
 version available in newer kernels.
 .TP
 .IR \fB\-\-cachepool " " CachePoolLogicalVolume { Name | Path }


