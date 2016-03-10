From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 10 Mar 2016 21:41:06 +0000 (UTC)
Subject: master - man: vgcreate shared
Message-ID: <20160310214106.37B0961073@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6807eb88634fd0db95cdccbbc65570b2d96c989a
Commit:        6807eb88634fd0db95cdccbbc65570b2d96c989a
Parent:        0f10823ec910c0a6015b20580f5aa26f209cea04
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 10 15:40:37 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 10 15:40:37 2016 -0600

man: vgcreate shared

---
 man/vgcreate.8.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index 92ef06c..22feedf 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -132,7 +132,8 @@ The 2.4 kernel has a limitation of 2TiB per block device.
 .B \-\-shared
 Create a shared VG using lvmlockd.  lvmlockd will select lock type sanlock
 or dlm depending on which lock manager is running.  This allows multiple
-hosts to share a VG on shared devices.  See
+hosts to share a VG on shared devices.  lvmlockd and a lock manager must
+be configured and running.  See
 .BR lvmlockd (8).
 
 .TP


