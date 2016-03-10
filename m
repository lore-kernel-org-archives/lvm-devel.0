From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:13 +0000 (UTC)
Subject: master - man: drop extra braces
Message-ID: <20160310174013.6547860EB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a494d85ef6cf00a6a61707e5bc41aa59bb17b7e6
Commit:        a494d85ef6cf00a6a61707e5bc41aa59bb17b7e6
Parent:        386208e5933ea40792c402bce17f3ff106aa3353
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 4 21:59:04 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:54 2016 +0100

man: drop extra braces

doclifter tool noticed wrong brackets.
---
 man/lvreduce.8.in |    5 +++--
 man/vgchange.8.in |    2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/man/lvreduce.8.in b/man/lvreduce.8.in
index 120afb7..5aca24e 100644
--- a/man/lvreduce.8.in
+++ b/man/lvreduce.8.in
@@ -15,8 +15,9 @@ lvreduce \(em reduce the size of a logical volume
 .RB [ \-f | \-\-force ]
 .RB [ \-\-noudevsync ]
 .RB { \-l | \-\-extents
-.RI [ \- ] LogicalExtentsNumber [ % { VG | LV | FREE | ORIGIN "}] |"
-.RB [ \-L | \-\-size
+.RI [ \- ] LogicalExtentsNumber [ % { VG | LV | FREE | ORIGIN }]
+.RB |
+.BR \-L | \-\-size
 .RI [ \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
 .RB [ \-n | \-\-nofsck ]
 .RB [ \-r | \-\-resizefs ]
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index fd7ee9d..6e13f5f 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -44,7 +44,7 @@ vgchange \(em change attributes of a volume group
 .IR MaxPhysicalVolumes ]
 .RB [ \-\-metadataprofile
 .IR ProfileName ]
-.RB [ \-\- [ vg ] metadatacopies ]
+.RB [ \-\- [ vg ] metadatacopies
 .IR NumberOfCopies | unmanaged | all ]
 .RB [ \-P | \-\-partial ]
 .RB [ \-s | \-\-physicalextentsize


