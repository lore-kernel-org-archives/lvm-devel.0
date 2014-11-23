From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 23 Nov 2014 23:03:18 +0000 (UTC)
Subject: master - man/lvchange: Mention --cachepolicy and --cachesettings.
Message-ID: <20141123230318.BA95E6055D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ced0c17f2179af623cfec72e5a52f93471cda676
Commit:        ced0c17f2179af623cfec72e5a52f93471cda676
Parent:        1445a74d76ddf59043e0e713c6a96eddc4839670
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Nov 23 23:42:20 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Nov 24 00:02:55 2014 +0100

man/lvchange: Mention --cachepolicy and --cachesettings.

---
 man/lvchange.8.in |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index cafb914..4577cce 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -16,6 +16,10 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-K | \-\-ignoreactivationskip ]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
+.RB [ \-\-cachepolicy
+.IR policy ]
+.RB [ \-\-cachesettings
+.IR key=value ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-C | \-\-contiguous
@@ -131,6 +135,11 @@ of the flag is reported within \fBlv_attr\fP bits.
 .BR \-K ", " \-\-ignoreactivationskip
 Ignore the flag to skip Logical Volumes during activation.
 .TP
+.BR  \-\-cachepolicy " " policy ", " \-\-cachesettings " " key=value
+Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
+the cache policy and its associated tunable settings. In most use-cases,
+default values should be adequate.
+.TP
 .BR \-C ", " \-\-contiguous " {" \fIy | \fIn }
 Tries to set or reset the contiguous allocation policy for
 logical volumes. It's only possible to change a non-contiguous


