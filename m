From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 21:31:42 +0000 (UTC)
Subject: master - man: lvcreate doc passthrough
Message-ID: <20160426213142.BA5616096D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07d92322c13e942b8a47b4370a82b70d33a6f0c8
Commit:        07d92322c13e942b8a47b4370a82b70d33a6f0c8
Parent:        d90d99b23d94dea41b65166f8bb19cb2883e527c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 25 13:38:24 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 26 23:29:58 2016 +0200

man: lvcreate doc passthrough

Add few more words about passthough mode.
---
 man/lvcreate.8.in |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index f6bb14f..fd8b3a7 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -219,7 +219,10 @@ If \fBwritethough\fP is specified, a write is considered complete only
 when it has been stored in the cache pool LV and on the origin LV.
 While \fBwritethrough\fP may be slower for writes, it is more
 resilient if something should happen to a device associated with the
-cache pool LV.
+cache pool LV. With \fBpassthrough\fP mode, all reads are served
+from origin LV (all reads miss the cache) and all writes are
+forwarded to the origin LV; additionally, write hits cause cache
+block invalidates. See \fBlvmcache(7)\fP for more details.
 .
 .HP
 .BR \-\-cachepolicy


