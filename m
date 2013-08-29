From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 29 Aug 2013 12:21:24 +0000 (UTC)
Subject: master - man: lvmdump -u -l
Message-ID: <20130829122124.29DB5613C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c36dcc17282cf9c5f745cc627f9ce3825b4ee5e2
Commit:        c36dcc17282cf9c5f745cc627f9ce3825b4ee5e2
Parent:        78647da1c66106e3e8f310cd37742d196e195c96
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 29 14:20:57 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 29 14:20:57 2013 +0200

man: lvmdump -u -l

---
 man/lvmdump.8.in |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/man/lvmdump.8.in b/man/lvmdump.8.in
index 306ae39..5e355de 100644
--- a/man/lvmdump.8.in
+++ b/man/lvmdump.8.in
@@ -8,7 +8,9 @@ lvmdump - create lvm2 information dumps for diagnostic purposes
 .RB [ \-d
 .IR directory ]
 .RB [ \-h ]
+.RB [ \-l ]
 .RB [ \-m ]
+.RB [ \-u ]
 .SH DESCRIPTION
 lvmdump is a tool to dump various information concerning LVM2.
 By default, it creates a tarball suitable for submission along


