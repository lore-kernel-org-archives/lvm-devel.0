From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  4 Mar 2015 13:14:03 +0000 (UTC)
Subject: master - systemid: Disable --systemid.
Message-ID: <20150304131404.041786104E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=733bfe36f5ba34f11b297e41ec249aaa6b238d7b
Commit:        733bfe36f5ba34f11b297e41ec249aaa6b238d7b
Parent:        67c52a4453a941244b07044ee1b80284e8f181c6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 4 13:14:51 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 4 13:14:51 2015 +0000

systemid: Disable --systemid.

Disable use of --systemid for this release.
---
 tools/commands.h |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 719c507..577589e 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -965,7 +965,6 @@ xx(vgchange,
    "\t[--refresh]\n"
    "\t[-S|--select Selection]\n"
    "\t[--sysinit]\n"
-   "\t[--systemid SystemID]\n"
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"
    "\t[-v|--verbose]\n"
@@ -988,7 +987,7 @@ xx(vgchange,
    metadataprofile_ARG, monitor_ARG, noudevsync_ARG, metadatacopies_ARG,
    vgmetadatacopies_ARG, partial_ARG, physicalextentsize_ARG, poll_ARG,
    refresh_ARG, resizeable_ARG, resizable_ARG, select_ARG, sysinit_ARG,
-   systemid_ARG, test_ARG, uuid_ARG)
+   test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
@@ -1039,7 +1038,6 @@ xx(vgcreate,
    "\t[--[vg]metadatacopies #copies]\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes]\n"
    "\t[-s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE]]\n"
-   "\t[--systemid SystemID]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
@@ -1051,8 +1049,7 @@ xx(vgcreate,
    maxphysicalvolumes_ARG, metadataprofile_ARG, metadatatype_ARG,
    physicalextentsize_ARG, test_ARG, force_ARG, zero_ARG, labelsector_ARG,
    metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
-   vgmetadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG,
-   systemid_ARG)
+   vgmetadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG)
 
 xx(vgdisplay,
    "Display volume group information",


