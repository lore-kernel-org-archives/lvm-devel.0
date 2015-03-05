From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  5 Mar 2015 15:49:57 +0000 (UTC)
Subject: master - system_id: enable the options in config file and command line
Message-ID: <20150305154957.05C71610F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06b408ecce9d95f768ace998b83674140bc05abc
Commit:        06b408ecce9d95f768ace998b83674140bc05abc
Parent:        190d591fbec672a2e1f77d4709fcee75cc695a06
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 4 11:15:45 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 5 09:50:43 2015 -0600

system_id: enable the options in config file and command line

---
 lib/config/config_settings.h |    8 ++++----
 tools/commands.h             |    7 +++++--
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f22039a..ef78182 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -194,8 +194,8 @@ cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECT
 cfg(global_cache_dump_executable_CFG, "cache_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_DUMP_CMD, vsn(2, 2, 108), NULL)
 cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_REPAIR_CMD, vsn(2, 2, 108), NULL)
 cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL)
-cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, CFG_DISABLED, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL)
-cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DISABLED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL)
+cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
 
 cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION_CHECKS, vsn(2, 2, 86), NULL)
 cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL)
@@ -282,7 +282,7 @@ cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_H
 cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18), NULL)
 cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
 
-cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_DISABLED | CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
-cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_DISABLED | CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
 
 cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL)
diff --git a/tools/commands.h b/tools/commands.h
index 577589e..719c507 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -965,6 +965,7 @@ xx(vgchange,
    "\t[--refresh]\n"
    "\t[-S|--select Selection]\n"
    "\t[--sysinit]\n"
+   "\t[--systemid SystemID]\n"
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"
    "\t[-v|--verbose]\n"
@@ -987,7 +988,7 @@ xx(vgchange,
    metadataprofile_ARG, monitor_ARG, noudevsync_ARG, metadatacopies_ARG,
    vgmetadatacopies_ARG, partial_ARG, physicalextentsize_ARG, poll_ARG,
    refresh_ARG, resizeable_ARG, resizable_ARG, select_ARG, sysinit_ARG,
-   test_ARG, uuid_ARG)
+   systemid_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
@@ -1038,6 +1039,7 @@ xx(vgcreate,
    "\t[--[vg]metadatacopies #copies]\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes]\n"
    "\t[-s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE]]\n"
+   "\t[--systemid SystemID]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
@@ -1049,7 +1051,8 @@ xx(vgcreate,
    maxphysicalvolumes_ARG, metadataprofile_ARG, metadatatype_ARG,
    physicalextentsize_ARG, test_ARG, force_ARG, zero_ARG, labelsector_ARG,
    metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
-   vgmetadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG)
+   vgmetadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG,
+   systemid_ARG)
 
 xx(vgdisplay,
    "Display volume group information",


