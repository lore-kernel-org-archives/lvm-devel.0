From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 11 Dec 2014 09:43:39 +0000 (UTC)
Subject: master - man: remove reference to --binary in {pv, vg, lv}display man page
Message-ID: <20141211094339.359266098C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ec482a3797261d867c097963e65c03306f01c97
Commit:        3ec482a3797261d867c097963e65c03306f01c97
Parent:        b21a8412c482ae735d0d044d355e1541ccba6edf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 11 10:40:28 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 11 10:42:31 2014 +0100

man: remove reference to --binary in {pv,vg,lv}display man page

The {pv,vg,lv}display commands don't use reporting capabilites and
as such they can't use --binary. This got into the man pages by
mistake - the display commands do not recognize --binary option.
---
 man/lvdisplay.8.in |    1 -
 man/pvdisplay.8.in |    1 -
 man/vgdisplay.8.in |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index 3232853..1881b3f 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -25,7 +25,6 @@ lvdisplay \(em display attributes of a logical volume
 .B lvdisplay
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
-.RB [ \-\-binary ]
 .RB [ \-a | \-\-all ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index 70c9bfc..0399c1e 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -26,7 +26,6 @@ pvdisplay \- display attributes of a physical volume
 .B pvdisplay
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
-.RB [ \-\-binary ]
 .RB [ \-a | \-\-all ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index 1e472d3..97cb314 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -26,7 +26,6 @@ vgdisplay \(em display attributes of volume groups
 .B vgdisplay
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
-.RB [ \-\-binary ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]


