From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 20 May 2014 14:28:47 +0000 (UTC)
Subject: master - commands: do not register profile_ARG for lvcreate/lvchange separetely
Message-ID: <20140520142847.861976011B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22cab9c481c853cb58aef4b5836f74b3ddfd586c
Commit:        22cab9c481c853cb58aef4b5836f74b3ddfd586c
Parent:        24f32721a9e6a61943122f3d06d2329f5f81597c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 19 16:29:06 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon May 19 16:30:49 2014 +0200

commands: do not register profile_ARG for lvcreate/lvchange separetely

The --profile is globally available for all commands.
---
 tools/commands.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 21a2075..5a69e44 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -139,10 +139,10 @@ xx(lvchange,
    ignoreskippedcluster_ARG,
    major_ARG, minor_ARG, monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG,
    noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG, poll_ARG,
-   profile_ARG, raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG,
-   raidsyncaction_ARG, raidwritebehind_ARG, raidwritemostly_ARG, readahead_ARG,
-   resync_ARG, refresh_ARG, setactivationskip_ARG, syncaction_ARG, sysinit_ARG,
-   test_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
+   raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG, raidsyncaction_ARG,
+   raidwritebehind_ARG, raidwritemostly_ARG, readahead_ARG, resync_ARG,
+   refresh_ARG, setactivationskip_ARG, syncaction_ARG, sysinit_ARG, test_ARG,
+   writebehind_ARG, writemostly_ARG, zero_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -894,7 +894,7 @@ xx(vgchange,
    ignoreactivationskip_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    ignoreskippedcluster_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
-   metadatacopies_ARG, vgmetadatacopies_ARG, partial_ARG, profile_ARG,
+   metadatacopies_ARG, vgmetadatacopies_ARG, partial_ARG,
    physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
    resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
 


