From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:54 +0100
Subject: [PATCH 13/15] Add --keyfile option.
In-Reply-To: <8063c7b937ce3760c31028df5e6689d2bb35fde1.1232488181.git.mbroz@redhat.com>
References: <cover.1232488181.git.mbroz@redhat.com>
	<f798c95b982dd875729f4c43b4cb7667965ea41a.1232488181.git.mbroz@redhat.com>
	<1778134dc3683bb96cc98ad243d673be1175880a.1232488181.git.mbroz@redhat.com>
	<589f0ab5ed9a4e91eeb4fefd9a46e0c873af0e2a.1232488181.git.mbroz@redhat.com>
	<b43d35ebbdda1be4696b072c222c243cb0645f72.1232488181.git.mbroz@redhat.com>
	<3417d8a2769cc152bd8aef5921716b693360ee15.1232488181.git.mbroz@redhat.com>
	<6d887c3c90806a55ac1cf569425845ce0ed16daa.1232488181.git.mbroz@redhat.com>
	<0cf2e4e850e1c919e0e6bc98504be6d5087caa1c.1232488181.git.mbroz@redhat.com>
	<b8d375b5ca799bd88ff701ba19b93bed02f62343.1232488181.git.mbroz@redhat.com>
	<3d899235af519a0e471dc86df580a991371b91fd.1232488181.git.mbroz@redhat.com>
	<35fcbf3ab1527b121e3a8064a35eab8f7a7a2f1d.1232488181.git.mbroz@redhat.com>
	<11624519b513cc630635406dc8b35f380bb43a9f.1232488181.git.mbroz@redhat.com>
	<8063c7b937ce3760c31028df5e6689d2bb35fde1.1232488181.git.mbroz@redhat.com>
Message-ID: <56eb4722a65edf5a12d79098ab2ec848b3e727b4.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow input of key from file (or standard input)
by specifying --keyfile on commandline.

If the file is "-" stdin is used, e.g.
echo $key | lvcreate ...

(It is not safe, but useful in scripts. Similar approach
is used in cryptsetup.)

Currently supported only for lvcreate, vgchange, lvchange.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/args.h     |    1 +
 tools/commands.h |   17 +++++++++--------
 tools/lvchange.c |    7 +++++++
 tools/lvcreate.c |    7 +++++++
 tools/vgchange.c |    7 +++++++
 5 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index a1347ea..cacbb2b 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -60,6 +60,7 @@ arg(rows_ARG, '\0', "rows", NULL, 0)
 arg(crypt_ARG, '\0', "crypt", string_arg, 0)
 arg(cipher_ARG, '\0', "cipher", string_arg, 0)
 arg(keysize_ARG, '\0', "keysize", int_arg, 0)
+arg(keyfile_ARG, '\0', "keyfile", string_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index deb300b..07c472e 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -85,9 +85,10 @@ xx(lvchange,
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    alloc_ARG, autobackup_ARG, available_ARG, contiguous_ARG, force_ARG,
-   ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
-   monitor_ARG, partial_ARG, permission_ARG, persistent_ARG, readahead_ARG,
-   resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG, yes_ARG)
+   ignorelockingfailure_ARG, ignoremonitoring_ARG, keyfile_ARG, major_ARG,
+   minor_ARG, monitor_ARG, partial_ARG, permission_ARG, persistent_ARG,
+   readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG,
+   yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -136,7 +137,7 @@ xx(lvcreate,
    "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
-   "\t[--crypt KeyStoreType --cipher Cipher --keysize KeySize]\n"
+   "\t[--crypt KeyStoreType --cipher Cipher --keysize KeySize [--keyfile filename]]\n"
    "\t[--crypt TemplateLogicalVolume[Path]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
@@ -171,7 +172,7 @@ xx(lvcreate,
 
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, cipher_ARG,
    contiguous_ARG, corelog_ARG, crypt_ARG, extents_ARG, keysize_ARG,
-   major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG,
+   keyfile_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG,
    nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
    regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
    test_ARG, type_ARG, zero_ARG)
@@ -689,9 +690,9 @@ xx(vgchange,
 
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
-   logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, partial_ARG,
-   physicalextentsize_ARG, refresh_ARG, resizeable_ARG, resizable_ARG,
-   test_ARG, uuid_ARG)
+   keyfile_ARG, logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG,
+   partial_ARG, physicalextentsize_ARG, refresh_ARG, resizeable_ARG,
+   resizable_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
diff --git a/tools/lvchange.c b/tools/lvchange.c
index cd0ff5a..0a4778f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -728,6 +728,13 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, keyfile_ARG) &&
+	    !lvm_set_password_dev(arg_value(cmd, keyfile_ARG))) {
+		log_error("--keyfile argument %s is invalid",
+			  arg_value(cmd, keyfile_ARG));
+		return EINVALID_CMD_LINE;
+	}
+
 	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
 			       &lvchange_single);
 }
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e0f59be..6eea76d 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -342,6 +342,13 @@ static int _read_crypt_params(struct lvcreate_params *lp,
 	if (!arg_count(cmd, crypt_ARG))
 		return 1;
 
+	if (arg_count(cmd, keyfile_ARG) &&
+	    !lvm_set_password_dev(arg_value(cmd, keyfile_ARG))) {
+		log_error("--keyfile argument %s is invalid",
+			  arg_value(cmd, keyfile_ARG));
+		return 0;
+	}
+
 	if (arg_count(cmd, cipher_ARG)) {
 		/*
 		 * Explicit cipher specification
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 8831a23..ed00744 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -631,6 +631,13 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, keyfile_ARG) &&
+	    !lvm_set_password_dev(arg_value(cmd, keyfile_ARG))) {
+		log_error("--keyfile argument %s is invalid",
+			  arg_value(cmd, keyfile_ARG));
+		return EINVALID_CMD_LINE;
+	}
+
 	return process_each_vg(cmd, argc, argv,
 			       (arg_count(cmd, available_ARG)) ?
 			       LCK_VG_READ : LCK_VG_WRITE, 0, NULL,
-- 
1.5.6.5


