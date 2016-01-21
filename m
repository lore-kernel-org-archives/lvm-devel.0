From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Jan 2016 11:12:16 +0000 (UTC)
Subject: master - man: show hidden pieces
Message-ID: <20160121111216.C9B1960E4C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e09f916b4d4b4e93372305f90f5f22ce227c51a
Commit:        3e09f916b4d4b4e93372305f90f5f22ce227c51a
Parent:        640c45d5a4da1a1cedf47b5a7f27b05e1fd00d76
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 21 11:31:18 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 21 12:11:35 2016 +0100

man: show hidden pieces

W: manual-page-warning /usr/share/man/man8/lvm.8.gz 491: warning: macro `_cdata',' not defined

rpmlint actually notices we had few hidden word in man page.
the line cannot start with apostrophe as it has then a different
meaning.
---
 WHATS_NEW    |    1 +
 man/lvm.8.in |    8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 20f86d2..0a9e17a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.141 - 
 ====================================
+  Fix lvm.8 man to show again prohibited suffixes.
   Fix configure to set proper use_blkid_wiping if autodetected as disabled.
   Initialise udev in clvmd for use in device scanning. (2.02.116)
   Add seg_le_ranges report field for common format when displaying seg devices.
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 4e9e1dd..4f801c9 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -402,8 +402,8 @@ Characters allowed in tags are:
 .BR 0 - 9
 .BR "_ + . -"
 and as of version 2.02.78 the following characters are also accepted:
-.BR "/ = ! : # &"
-..
+.BR "/ = ! : # &" .
+.
 .HP
 .BR \-\-deltag
 .IR Tag
@@ -488,8 +488,8 @@ not be used as LV or VG names. A VG cannot be called anything that exists in
 \fI/dev/\fP at the time of creation, nor can it be called '.' or '..'.
 An LV cannot be called '.', '..', 'snapshot' or 'pvmove'.
 The LV name may also not contain any of the following strings:
-'_cdata', '_cmeta', '_corig', '_mlog', '_mimage', '_pmspare', '_rimage',
-'_rlog', '_tdata' or '_tmeta'.
+\fR'_cdata', '_cmeta', '_corig', '_mlog', '_mimage', '_pmspare',
+\fR'_rimage', '_rlog', '_tdata' or '_tmeta'.
 A directory bearing the name of each Volume Group is created under
 \fI/dev\fP when any of its Logical Volumes are activated.
 Each active Logical Volume is accessible from this directory as a symbolic


