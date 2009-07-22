From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 00:05:52 -0400
Subject: [PATCH 7/8] Add metadatatype arg to vgextend.
In-Reply-To: <1248235553-13519-7-git-send-email-dwysocha@redhat.com>
References: <1248235553-13519-1-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-2-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-3-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-4-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-5-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-6-git-send-email-dwysocha@redhat.com>
	<1248235553-13519-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1248235553-13519-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If any devices need an implicit pvcreate, we must know the metadata
type.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/vgextend.8.in |    1 +
 tools/commands.h  |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/man/vgextend.8.in b/man/vgextend.8.in
index deb1cf3..25a2fc2 100644
--- a/man/vgextend.8.in
+++ b/man/vgextend.8.in
@@ -4,6 +4,7 @@ vgextend \- add physical volumes to a volume group
 .SH SYNOPSIS
 .B vgextend
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help] 
+[\-M|\-\-metadatatype type]
 [\-t|\-\-test]
 [\-v|\-\-verbose]
 VolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]
diff --git a/tools/commands.h b/tools/commands.h
index 8559799..6ac2fe3 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -800,12 +800,13 @@ xx(vgextend,
    "\t[-A|--autobackup y|n]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
+   "\t[-M|--metadatatype 1|2]" "\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
 
-   autobackup_ARG, test_ARG)
+   autobackup_ARG, metadatatype_ARG, test_ARG)
 
 xx(vgimport,
    "Register exported volume group with system",
-- 
1.6.0.6


