From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Aug 2015 09:29:24 +0000 (UTC)
Subject: master - man: replace to with for
Message-ID: <20150826092924.5A67361188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1307fafe0f72cea9b3f2e7e7fdb70b1b5d0a0670
Commit:        1307fafe0f72cea9b3f2e7e7fdb70b1b5d0a0670
Parent:        9886fd236e2cf09f299589e0e2b6cb7454b2314a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 24 11:20:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 26 11:24:41 2015 +0200

man: replace to with for

Better word.
---
 man/lvconvert.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index c2ee2b2..4438893 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -326,7 +326,7 @@ operation from its arguments.
 Separates \fICacheLogicalVolume\fP from cache pool.
 Before the logical volume becomes uncached, cache is flushed.
 The cache pool volume is then left unused and
-could be used e.g. to caching another volume.
+could be used e.g. for caching another volume.
 See also the option \fB\-\-uncache\fP for uncaching and removing
 cache pool with one command.
 .TP


