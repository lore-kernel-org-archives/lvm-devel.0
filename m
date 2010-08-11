From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 11 Aug 2010 17:07:57 -0400
Subject: [PATCH 3/2] document --norestorefile in pvcreate man page
In-Reply-To: <1281479088-1553-1-git-send-email-snitzer@redhat.com>
References: <1281479088-1553-1-git-send-email-snitzer@redhat.com>
Message-ID: <20100811210756.GA8422@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

document --norestorefile in pvcreate man page

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 man/pvcreate.8.in |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

Index: lvm2/man/pvcreate.8.in
===================================================================
--- lvm2.orig/man/pvcreate.8.in
+++ lvm2/man/pvcreate.8.in
@@ -17,6 +17,7 @@ pvcreate \- initialize a disk or partiti
 .RB [ \-\-dataalignment alignment ]
 .RB [ \-\-dataalignmentoffset alignment_offset ]
 .RB [ \-\-restorefile file ]
+.RB [ \-\-norestorefile ]
 .RB [ \-\-setphysicalvolumesize size ]
 .RB [ \-u | \-\-uuid uuid ]
 .RB [ \-\-version ]
@@ -60,7 +61,9 @@ Specify the uuid for the device.  
 Without this option, \fBpvcreate\fP generates a random uuid.
 All of your physical volumes must have unique uuids.
 You need to use this option before restoring a backup of LVM metadata 
-onto a replacement device - see \fBvgcfgrestore\fP(8).
+onto a replacement device - see \fBvgcfgrestore\fP(8).  As such, use of
+\fB--restorefile\fP is compulsory unless the \fB--norestorefile\fP is
+used.
 .TP
 .BR \-y ", " \-\-yes
 Answer yes to all questions.
@@ -138,6 +141,10 @@ the same place and not get overwritten b
 a mechanism to upgrade the metadata format or to add/remove metadata
 areas. Use with care. See also \fBvgconvert\fP(8).
 .TP
+.BR \-\-norestorefile
+In conjunction with \fB--uuid\fP, this allows a uuid to be specified
+without also requiring that a backup of the metadata be provided.
+.TP
 .BR \-\-labelsector " sector"
 By default the PV is labelled with an LVM2 identifier in its second 
 sector (sector 1).  This lets you use a different sector near the


