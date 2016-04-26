From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 21:31:40 +0000 (UTC)
Subject: master - man: lvchange updates
Message-ID: <20160426213140.9F1D660663@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d90d99b23d94dea41b65166f8bb19cb2883e527c
Commit:        d90d99b23d94dea41b65166f8bb19cb2883e527c
Parent:        e77b6968b6b420a4d0d9f14af1386f28761f055b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 24 11:40:59 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 26 23:29:58 2016 +0200

man: lvchange updates

Drop never existing --degrade.
---
 man/lvchange.8.in |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index fb16530..34ce583 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -26,15 +26,14 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-A | \-\-autobackup
 .RB { y | n }]
 .RB [ \-\-cachepolicy
-.IR policy ]
+.IR Policy ]
 .RB [ \-\-cachesettings
-.IR key \fB= value ]
+.IR Key \fB= Value ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-C | \-\-contiguous
 .RB { y | n }]
 .RB [ \-d | \-\-debug ]
-.RB [ \-\-degraded ]
 .RB [ \-\-deltag
 .IR Tag ]
 .RB [ \-\-detachprofile ]
@@ -57,9 +56,9 @@ lvchange \(em change attributes of a logical volume
 .RB [ \-M | \-\-persistent
 .RB { y | n }
 .RB [ \-\-major
-.IR major ]
+.IR Major ]
 .RB [ \-\-minor
-.IR minor ]]
+.IR Minor ]]
 .RB [ \-\-poll
 .RB { y | n }]
 .RB [ \-\- [ raid ] maxrecoveryrate
@@ -188,9 +187,9 @@ of the flag is reported within \fBlv_attr\fP bits.
 .
 .HP
 .BR  \-\-cachepolicy
-.IR policy ,
+.IR Policy ,
 .BR \-\-cachesettings
-.IR key \fB= value
+.IR Key \fB= Value
 .br
 Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
 the cache policy and its associated tunable settings. In most use-cases,
@@ -240,7 +239,7 @@ Do not use this if dmeventd is already monitoring a device.
 .
 .HP
 .BR \-\-major
-.IR major
+.IR Major
 .br
 Sets the major number. This option is supported only on older systems
 (kernel version 2.4) and is ignored on modern Linux systems where major
@@ -248,7 +247,7 @@ numbers are dynamically assigned.
 .
 .HP
 .BR \-\-minor
-.IR minor
+.IR Minor
 .br
 Set the minor number.
 .


