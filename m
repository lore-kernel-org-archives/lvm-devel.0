From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Jul 2016 12:42:33 +0000 (UTC)
Subject: master - man: drop .R
Message-ID: <20160722124233.A764460FAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bb113c20469aa5027098465ddeaa3c652d4f8e5
Commit:        5bb113c20469aa5027098465ddeaa3c652d4f8e5
Parent:        27a767d5e8cedf9cac31eb3562cf8fdd4aa88b7c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 21 14:56:30 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 22 14:41:47 2016 +0200

man: drop .R

Avoid using .R as its not a valid man macro.
---
 man/lvconvert.8.in |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 95f7095..5ddea3d 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -92,9 +92,9 @@ OPTIONS:
 .B \-\-type striped
 .br
 .B \-\-type snapshot
-.R |
+|
 .B \-\-snapshot
-.R |
+|
 .B \-s
 .br
 .B \-\-type mirror
@@ -102,15 +102,15 @@ OPTIONS:
 .B \-\-type raid*
 .br
 .B \-\-type thin
-.R |
+|
 .B \-\-thin
-.R |
+|
 .B \-T
 .br
 .B \-\-type cache
-.R |
+|
 .B \-\-cache
-.R |
+|
 .B \-H
 .br
 .B \-\-type thin\-pool


