From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 25 Feb 2015 17:33:58 +0000 (UTC)
Subject: master - lvcreate.8: Mention --cachepolicy and --cachesettings.
Message-ID: <20150225173358.A6FFC61054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a88430c6a1e072f326bf4f20fbfd6c11735d0e91
Commit:        a88430c6a1e072f326bf4f20fbfd6c11735d0e91
Parent:        0d313282f2f824e321c5a78bec2ab0c5cc37f2d1
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Feb 25 18:34:01 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Feb 25 18:34:01 2015 +0100

lvcreate.8: Mention --cachepolicy and --cachesettings.

---
 man/lvcreate.8.in |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 8c1ee4b..de4f168 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -14,6 +14,10 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-H | \-\-cache ]
 .RB [ \-\-cachemode
 .RI { writeback | writethrough }]
+.RB [ \-\-cachepolicy
+.IR policy ]
+.RB [ \-\-cachesettings
+.IR key=value ]
 .RB [ \-\-cachepool
 .IR CachePoolLogicalVolume { Name | Path }
 .RB [ \-c | \-\-chunksize
@@ -246,6 +250,11 @@ Ignore the flag to skip Logical Volumes during activation.
 Use \fB\-\-setactivationskip\fP option to set or reset
 activation skipping flag persistently for logical volume.
 .TP
+.BR  \-\-cachepolicy " " policy ", " \-\-cachesettings " " key=value
+Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
+the cache policy and its associated tunable settings. In most use-cases,
+default values should be adequate.
+.TP
 .B \-\-ignoremonitoring
 Make no attempt to interact with dmeventd unless \fB\-\-monitor\fP
 is specified.


