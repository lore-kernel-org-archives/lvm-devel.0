From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 11 Sep 2015 19:35:22 +0000 (UTC)
Subject: master - man lvmlockd: move and update text about vgremove
Message-ID: <20150911193522.E628860D23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b8103efef9cc23eb8fe47cd7d16629560ffd2e3
Commit:        8b8103efef9cc23eb8fe47cd7d16629560ffd2e3
Parent:        6bc3d72a655395a7f1ca299d85000ff65280d24d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 11 14:34:22 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 11 14:34:22 2015 -0500

man lvmlockd: move and update text about vgremove

The requirement to stop VGs before vgremove applies
to both sanlock and dlm VGs.
---
 man/lvmlockd.8.in |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 8567651..4e7abdf 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -352,6 +352,10 @@ be displayed with 'vgs \-o+locktype,lockargs'.
 lockd VGs need to be "started" and "stopped", unlike other types of VGs.
 See the following section for a full description of starting and stopping.
 
+vgremove of a lockd VG will fail if other hosts have the VG started.
+Run vgchange \-\-lock-stop <vgname> on all other hosts before vgremove.
+(It may take several seconds before vgremove recognizes that all hosts
+have stopped a sanlock VG.)
 
 .SS starting and stopping VGs
 
@@ -567,12 +571,6 @@ change the VG lock type back to "sanlock".
 To place the lvmlock LV on a specific device, create the VG with only that
 device, then use vgextend to add other devices.
 
-vgremove of a sanlock VG will fail if other hosts have the VG started.
-Run vgchange \-\-lock-stop <vgname> on all other hosts before vgremove.
-(It may take several seconds before vgremove recognizes that all hosts
-have stopped.)  This is necessary because while a host has a sanlock VG
-started, it is using the internal lvmlock LV.
-
 
 .SS shared LVs
 


