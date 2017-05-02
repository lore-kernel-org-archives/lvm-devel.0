From: David Teigland <teigland@sourceware.org>
Date: Tue, 2 May 2017 16:51:47 -0400
Subject: master - man lvm: define LVM and its terms
Message-ID: <201705022051.v42KplEg017456@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=253bc5eb2e570fab788640e7256aeb52d1f51045
Commit:        253bc5eb2e570fab788640e7256aeb52d1f51045
Parent:        882a918befc8f09d30d913e66263b172dd503242
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 2 15:47:02 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 2 15:49:58 2017 -0500

man lvm: define LVM and its terms

The lvm(8) man page never said what LVM is,
it never defined what the acronym LVM stands for,
it never spelled out other common acronyms VG, PV, LV,
and never described what they are.

This adds a very minimal definition which at least defines
the acronyms and entities, but it could obviously be
expanded on, either here or elsewhere.
---
 man/lvm.8_main         |   16 ++++++++++++++--
 man/lvmsystemid.7_main |   11 ++++++-----
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/man/lvm.8_main b/man/lvm.8_main
index 31c4d7e..7506eaf 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -11,8 +11,20 @@ lvm \(em LVM2 tools
 .
 .SH DESCRIPTION
 .
-lvm provides the command-line tools for LVM2.  A separate
-manual page describes each command in detail.
+
+The Logical Volume Manager (LVM) provides tools to create virtual block
+devices from physical devices.  Virtual devices may be easier to manage
+than physical devices, and can have capabilities beyond what the physical
+devices provide themselves.  A Volume Group (VG) is a collection of one or
+more physical devices, each called a Physical Volume (PV).  A Logical
+Volume (LV) is a virtual block device that can be used by the system or
+applications.  Each block of data in an LV is stored on one or more PV in
+the VG, according to algorithms implemented by Device Mapper (DM) in the
+kernel.
+.P
+
+The lvm command, and other commands listed below, are the command-line
+tools for LVM.  A separate manual page describes each command in detail.
 .P
 If \fBlvm\fP is invoked with no arguments it presents a readline prompt
 (assuming it was compiled with readline support).
diff --git a/man/lvmsystemid.7_main b/man/lvmsystemid.7_main
index 1138e3f..c1db4c9 100644
--- a/man/lvmsystemid.7_main
+++ b/man/lvmsystemid.7_main
@@ -5,11 +5,12 @@ lvmsystemid \(em LVM system ID
 
 .SH DESCRIPTION
 
-The LVM system ID restricts VG access to one host.  This is useful when a
-VG is placed on shared storage devices, or when local devices are visible
-to both host and guest operating systems.  In cases like these, a VG can
-be visible to multiple hosts at once, and some mechanism is needed to
-protect it from being used by more than one host at a time.
+The \fBlvm\fP(8) system ID restricts VG access to one host.  This is
+useful when a VG is placed on shared storage devices, or when local
+devices are visible to both host and guest operating systems.  In cases
+like these, a VG can be visible to multiple hosts at once, and some
+mechanism is needed to protect it from being used by more than one host at
+a time.
 
 A VG's system ID identifies one host as the VG owner.  The host with a
 matching system ID can use the VG and its LVs, while LVM on other hosts


