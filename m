From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 17 Aug 2016 19:14:42 +0000 (UTC)
Subject: master - man: lvconvert change location of sentence
Message-ID: <20160817191442.4286460F1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0336b418281b6ea5b7972e90e5b125b624b1793f
Commit:        0336b418281b6ea5b7972e90e5b125b624b1793f
Parent:        c0a0eedf2e572b99e40384e68e3d5f8fba6f0ae5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 17 14:13:17 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 17 14:13:17 2016 -0500

man: lvconvert change location of sentence

The details about each option are explained in the
section for that option.
---
 man/lvconvert.8.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 4f4d05e..175a50c 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -338,8 +338,6 @@ VG/RaidLV
 \[bu]
 Change the number of images in raid1 RaidLV.
 
-Note the current maximum is 9 providing 10 raid1 legs.
-
 .B lvconvert \-\-splitmirrors
 Number
 VG/RaidLV
@@ -807,6 +805,8 @@ Specifies the number mirror images in addition to the original LV image,
 e.g. \fB\-\-mirrors 1\fP means two copies of the data, the original and
 one mirror image.
 
+The current maximum is 9 providing 10 raid1 images.
+
 This option is required when converting an LV to a \fBraid1\fP or
 \fBmirror\fP LV.
 


