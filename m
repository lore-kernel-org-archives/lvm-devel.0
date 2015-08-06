From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  6 Aug 2015 15:06:45 +0000 (UTC)
Subject: master - man lvmcache: mention LVs must be in the same VG
Message-ID: <20150806150645.37B0960E1D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c013e7ae29a9e3aa20930a24f3fcf0637ef1e91
Commit:        1c013e7ae29a9e3aa20930a24f3fcf0637ef1e91
Parent:        fd1782b5fc41f3b9aceba6c27ba23098b0b4b6e2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 6 10:05:12 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 6 10:06:21 2015 -0500

man lvmcache: mention LVs must be in the same VG

---
 man/lvmcache.7.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 433746b..7257386 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -16,7 +16,7 @@ origin LV to increase speed.  The cache metadata LV holds the
 accounting information that specifies where data blocks are stored (e.g.
 on the origin LV or on the cache data LV).  Users should be familiar with
 these LVs if they wish to create the best and most robust cached
-logical volumes.
+logical volumes.  All of these associated LVs must be in the same VG.
 
 .SH Cache Terms
 .nf


