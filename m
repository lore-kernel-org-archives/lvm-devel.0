From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  2 Jun 2016 12:07:18 +0000 (UTC)
Subject: master - man: lvmconfig: add note about --type diff and --mergedconfig
Message-ID: <20160602120718.90F656109A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8012c223e0beb858bc2a6b1ea809c4a98a90a5c1
Commit:        8012c223e0beb858bc2a6b1ea809c4a98a90a5c1
Parent:        687bc5cecfe6293ee5556aa4e448459bb5c167e6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 2 14:07:07 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 2 14:07:07 2016 +0200

man: lvmconfig: add note about --type diff and --mergedconfig

---
 man/lvmconfig.8.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index 257029e..f4b6abd 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -71,6 +71,7 @@ Display all possible configuration settings with default values assigned.
 .IP \fBdiff\fP 3
 Display all configuration settings for which the values used differ from defaults.
 The value assigned for each configuration setting is the value currently used.
+Using this type also implies the use of \fB\-\-mergedconfig\fP option.
 This is actually minimal LVM configuration which can be used without
 a change to current configured behaviour.
 .IP \fBfull\fP 3


