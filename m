From: Milan Broz <mbroz@redhat.com>
Date: Tue, 20 Apr 2010 12:27:14 +0200
Subject: [PATCH] Remove -n argument from vgcfgrestore.
Message-ID: <1271759234-32254-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is old lvm1 syntax, because arguments changed
frpm PVs to VGs compatibility is broken already.

name_ARG is not used in code.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/commands.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 5e44cb2..7d0185b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -688,14 +688,13 @@ xx(vgcfgrestore,
    "\t[-f|--file filename] " "\n"
    "\t[-l[l]|--list [--list]]" "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
-   "\t[-n|--name VolumeGroupName] " "\n"
    "\t[-h|--help]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
    "\tVolumeGroupName",
 
-   file_ARG, list_ARG, metadatatype_ARG, name_ARG, test_ARG)
+   file_ARG, list_ARG, metadatatype_ARG, test_ARG)
 
 xx(vgchange,
    "Change volume group attributes",
-- 
1.7.0.4


