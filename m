From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:42:05 +0000 (UTC)
Subject: master - man: lvconvert poolmetadataspare
Message-ID: <20140722204205.B265F6024D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b51f1b3df6c07f611ce364b4b662af7a2d1c9544
Commit:        b51f1b3df6c07f611ce364b4b662af7a2d1c9544
Parent:        d7d81e11574baad841def2fc1efb7a22ea44cd3e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 22 17:31:22 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 22 22:41:41 2014 +0200

man: lvconvert poolmetadataspare

Add missing description for --poolmetadataspare option.
---
 man/lvconvert.8.in |   11 +++++++++++
 man/lvcreate.8.in  |    4 ++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 032fbff..93fb9a9 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -118,6 +118,8 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 .RI { ReadAheadSectors | auto | none }]
 .RB [ \-\-stripes \ \fIStripes
 .RB [ \-I | \-\-stripesize \  \fIStripeSize ]]]
+.RB [ \-\-poolmetadataspare
+.RI { y | n }]
 .RB [ \-Z | \-\-zero \ { \fIy | \fIn }]]
 .RI [[ ExternalOrigin | ThinPool ] LogicalVolume { Name | Path }]
 .RI [ PhysicalVolume [ Path ][ :PE
@@ -141,6 +143,8 @@ lvconvert \(em convert a logical volume from linear to mirror or snapshot
 |
 .B \-\-poolmetadatasize
 .IR CachePoolMetadataSize [ bBsSkKmMgG ]}]
+.RB [ \-\-poolmetadataspare
+.RI { y | n }]
 .IR LogicalVolume { Name | Path }
 .RI [ PhysicalVolume [ Path ][ :PE [ \-PE ]]...]
 .RB [ \-\-commandprofile
@@ -373,6 +377,13 @@ The default value is estimated with this formula
 (Pool_LV_size / Pool_LV_chunk_size * 64b).
 Default unit is megabytes.
 .TP
+.IR \fB\-\-poolmetadataspare " {"  y | n }
+Controls creation and maintanence of pool metadata spare logical volume
+that will be used for automated pool recovery.
+Only one such volume is maintained within a volume group
+with the size of the biggest pool metadata volume.
+Default is \fIy\fPes.
+.TP
 .IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }
 Sets read ahead sector count of thin pool metadata logical volume.
 The default value is "\fIauto\fP" which allows the kernel to choose
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 4ae2b9a..5440ced 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -346,9 +346,9 @@ Default unit is megabytes.
 .TP
 .IR \fB\-\-poolmetadataspare " {"  y | n }
 Controls creation and maintanence of pool metadata spare logical volume
-that will be used for automated thin pool recovery.
+that will be used for automated pool recovery.
 Only one such volume is maintained within a volume group
-with the size of the biggest thin metadata volume.
+with the size of the biggest pool metadata volume.
 Default is \fIy\fPes.
 .TP
 .IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }


