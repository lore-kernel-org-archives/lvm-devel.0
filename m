From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:15:59 +0200
Subject: [PATCH 7/7] thin: add vgchange spare support
In-Reply-To: <cover.1373296467.git.zkabelac@redhat.com>
References: <cover.1373296467.git.zkabelac@redhat.com>
Message-ID: <7703f8121e5237840c86fe9c8b308686858b950e.1373296467.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Since the pool metadata spare could be seen as VG property
(only one such spare is supported per VG) - allow the manipulation
on vg level.

Support operation are:
removal --poolmetadata n   - removes spare LV if exists.
creation --poolmetadata y  - creates LV with maxsize of metadata

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 man/vgchange.8.in |  5 +++++
 tools/commands.h  |  2 ++
 tools/vgchange.c  | 25 +++++++++++++++++++++++--
 3 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index ab76ed0..c1872ea 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -39,6 +39,8 @@ vgchange \- change attributes of a volume group
 .RB [ \-P | \-\-partial ]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
+.RB [ \-\-poolmetadataspare
+.RI { y | n }]
 .RB [ \-\-refresh ]
 .RB [ -t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
@@ -196,6 +198,9 @@ impact on I/O performance to the logical volume.  The smallest PE is 1KiB.
 
 The 2.4 kernel has a limitation of 2TiB per block device.
 .TP
+.IR \fB\-\-poolmetadataspare " {" y | n }
+Change presence of pool metadata spare volume in this volume group.
+.TP
 .BR \-\-refresh
 If any logical volume in the volume group is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
diff --git a/tools/commands.h b/tools/commands.h
index cb4ef44..1ce32eb 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -784,6 +784,7 @@ xx(vgchange,
    "\t[--monitor {y|n}]\n"
    "\t[--[vg]metadatacopies #copies] " "\n"
    "\t[--poll {y|n}]\n"
+   "\t[--poolmetadataspare {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[--refresh]\n"
    "\t[--sysinit]\n"
@@ -806,6 +807,7 @@ xx(vgchange,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, logicalvolume_ARG,
    maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG, metadatacopies_ARG,
    vgmetadatacopies_ARG, partial_ARG, physicalextentsize_ARG, poll_ARG,
+   poolmetadataspare_ARG,
    refresh_ARG, resizeable_ARG, resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
diff --git a/tools/vgchange.c b/tools/vgchange.c
index d3e93f2..af75857 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -443,6 +443,25 @@ static int _vgchange_profile(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _vgchange_pool_metadata_spare(struct cmd_context *cmd,
+					 struct volume_group *vg)
+{
+	int pms = arg_int_value(cmd, poolmetadataspare_ARG, 0);
+	/* Defaults not used here, value is given on cmdline */
+
+	if (pms) {
+		if (!handle_pool_metadata_spare(vg, 0, NULL, 1))
+			return_0;
+	} else if (vg->pool_metadata_spare_lv) {
+		if (!vg_remove_pool_metadata_spare(vg))
+			return_0;
+	} else
+		log_warn("Volume group \"%s\" is already without "
+			 "pool metadata spare volume.", vg->name);
+
+	return 1;
+}
+
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute__((unused)))
@@ -464,6 +483,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		{ clustered_ARG, &_vgchange_clustered },
 		{ vgmetadatacopies_ARG, &_vgchange_metadata_copies },
 		{ profile_ARG, &_vgchange_profile},
+		{ poolmetadataspare_ARG, &_vgchange_pool_metadata_spare},
 		{ detachprofile_ARG, &_vgchange_profile},
 	};
 
@@ -545,6 +565,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, resizeable_ARG) ||
 		arg_count(cmd, uuid_ARG) ||
 		arg_count(cmd, physicalextentsize_ARG) ||
+		arg_count(cmd, poolmetadataspare_ARG) ||
 		arg_count(cmd, clustered_ARG) ||
 		arg_count(cmd, alloc_ARG) ||
 		arg_count(cmd, vgmetadatacopies_ARG);
@@ -557,8 +578,8 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	    !arg_count(cmd, refresh_ARG)) {
 		log_error("Need 1 or more of -a, -c, -l, -p, -s, -x, "
 			  "--refresh, --uuid, --alloc, --addtag, --deltag, "
-			  "--monitor, --poll, --vgmetadatacopies or "
-			  "--metadatacopies");
+			  "--monitor, --poll, --poolmetadataspare "
+			  "--vgmetadatacopies or --metadatacopies");
 		return EINVALID_CMD_LINE;
 	}
 
-- 
1.8.3.1


