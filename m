From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Apr 2015 19:22:43 +0000 (UTC)
Subject: master - config: edit descriptions
Message-ID: <20150415192243.4A71F60FC1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=105c07d1b4d34191ed939f53d98b253e620e449b
Commit:        105c07d1b4d34191ed939f53d98b253e620e449b
Parent:        5f6ac1c81274de2a3162764d7c4b14a80b3a5ae2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 15 14:21:20 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 15 14:21:20 2015 -0500

config: edit descriptions

Take some new information and wording from lvm.conf.5.
---
 lib/config/config_settings.h |  100 ++++++++++++++++++++++++++++++------------
 1 files changed, 72 insertions(+), 28 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 4dcec95..c0a732e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -107,16 +107,18 @@ cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_ADVANCED | CFG_P
 cfg_section(dmeventd_CFG_SECTION, "dmeventd", root_CFG_SECTION, 0, vsn(1, 2, 3),
 	"Settings for the LVM event daemon.\n")
 
-cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18), NULL)
+cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18),
+	"Host tag settings.\n")
+
 cfg_section(local_CFG_SECTION, "local", root_CFG_SECTION, 0, vsn(2, 2, 117),
 	"LVM settings that are specific to the local host.\n")
 
 cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 99),
 	"If enabled, any LVM configuration mismatch is reported.\n"
 	"This implies checking that the configuration key is understood\n"
-	"by LVM and that the value of the key is of a proper type.\n"
-	"If disabled, any configuration mismatch is ignored and default\n"
-	"value is used instead without any warning (a message about the\n"
+	"by LVM and that the value of the key is the proper type.\n"
+	"If disabled, any configuration mismatch is ignored and the default\n"
+	"value is used without any warning (a message about the\n"
 	"configuration key not being found is issued in verbose mode only).\n")
 
 cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99),
@@ -500,7 +502,7 @@ cfg(log_level_CFG, "level", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_LOGLEVEL,
 	"7 is the most verbose (LOG_DEBUG).\n")
 
 cfg(log_indent_CFG, "indent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_INDENT, vsn(1, 0, 0),
-	"indent messages according to their severity.\n")
+	"Indent messages according to their severity.\n")
 
 cfg(log_command_names_CFG, "command_names", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CMD_NAME, vsn(1, 0, 0),
 	"Display the command name on each line of output.\n")
@@ -544,10 +546,10 @@ cfg_runtime(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, 0, CFG_TY
 	"Remember to back up this directory regularly!\n")
 
 cfg(backup_retain_min_CFG, "retain_min", backup_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_ARCHIVE_NUMBER, vsn(1, 0, 0),
-	"The minimum number of archive files you wish to keep.\n")
+	"Minimum number of archives to keep.\n")
 
 cfg(backup_retain_days_CFG, "retain_days", backup_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_ARCHIVE_DAYS, vsn(1, 0, 0),
-	"The minimum time you wish to keep an archive file.\n")
+	"Minimum number of days to keep archive files.\n")
 
 cfg(shell_history_size_CFG, "history_size", shell_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_MAX_HISTORY, vsn(1, 0, 0),
 	"Number of lines of history to store in ~/.lvm_history.\n")
@@ -939,13 +941,17 @@ cfg(activation_use_linear_target_CFG, "use_linear_target", activation_CFG_SECTIO
 	"that only handles a single stripe.\n")
 
 cfg(activation_reserved_stack_CFG, "reserved_stack", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_STACK, vsn(1, 0, 0),
-	"Stack size in KB to reserve for use while devices are suspended.\n")
+	"Stack size in KB to reserve for use while devices are suspended.\n"
+	"Insufficent reserve risks I/O deadlock during device suspension.\n")
 
 cfg(activation_reserved_memory_CFG, "reserved_memory", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_MEMORY, vsn(1, 0, 0),
-	"Memory size in KB to reserve for use while devices are suspended.\n")
+	"Memory size in KB to reserve for use while devices are suspended.\n"
+	"Insufficent reserve risks I/O deadlock during device suspension.\n")
 
 cfg(activation_process_priority_CFG, "process_priority", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PROCESS_PRIORITY, vsn(1, 0, 0),
-	"Nice value used while devices are suspended.\n")
+	"Nice value used while devices are suspended.\n"
+	"Use a high priority so that LVs are suspended\n"
+	"for the shortest possible time.\n")
 
 cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY|CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18),
 	"Only LVs selected by this list are activated.\n"
@@ -1168,9 +1174,12 @@ cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION,
 cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_AUTO_SET_ACTIVATION_SKIP, vsn(2,2,99),
 	"Set the activation skip flag on new thin snapshot LVs.\n"
 	"An LV can have a persistent 'activation skip' flag.\n"
-	"The flag determines if the LV is skipped during activation.\n"
+	"The flag causes the LV to be skipped during normal activation.\n"
+	"The lvchange/vgchange -K option is required to activate LVs\n"
+	"that have the activation skip flag set.\n"
 	"When this setting is enabled, the activation skip flag is\n"
-	"set on new thin snapshot LVs.\n")
+	"set on new thin snapshot LVs.\n"
+	"The '--setactivationskip y|n' option overrides this setting.\n")
 
 cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ACTIVATION_MODE, vsn(2,2,108),
 	"How LVs with missing devices are activated.\n"
@@ -1193,9 +1202,12 @@ cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_
 cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0),
 	"Number of copies of metadata to store on each PV.\n"
 	"Possible options are: 0, 1, 2.\n"
-	"You may want to override this from the command line\n"
-	"with 0 when running pvcreate on new PVs which are to\n"
-	"be added to large VGs.\n")
+	"If set to 2, two copies of the VG metadata are stored on\n"
+	"the PV, one at the front of the PV, and one at the end.\n"
+	"If set to 1, one copy is stored at the front of the PV.\n"
+	"If set to 0, no copies are stored on the PV. This may\n"
+	"be useful with VGs containing large numbers of PVs.\n"
+	"The '--pvmetadatacopies' option overrides this setting.\n")
 
 cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69),
 	"Number of copies of metadata to maintain for each VG.\n"
@@ -1206,14 +1218,23 @@ cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG
 	"metadata is stored in them all.\n"
 	"The value 0 (unmanaged) disables this automatic management\n"
 	"and allows you to control which metadata areas are used at\n"
-	"the individual PV level using 'pvchange --metadataignore y|n'.\n")
+	"the individual PV level using 'pvchange --metadataignore y|n'.\n"
+	"The '--vgmetadatacopies' option overrides this setting.\n")
 
 cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_PVMETADATASIZE, vsn(1, 0, 0),
-	"Approximate default size of on-disk metadata areas in sectors.\n"
-	"Increase this if you have large volume groups or you want to\n"
-	"retain a large on-disk history of your metadata changes.\n")
+	"Approximate number of sectors to use for each metadata copy.\n"
+	"VGs with large numbers of PVs or LVs, or VGs containing\n"
+	"complex LV structures, may need additional space for VG\n"
+	"metadata. The metadata areas are treated as circular buffers,\n"
+	"so unused space becomes filled with an archive of the most\n"
+	"recent previous versions of the metadata.\n")
+
+cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_BOOL, DEFAULT_PVMETADATAIGNORE, vsn(2, 2, 69),
+	"Ignore metadata areas on a new PV.\n"
+	"If metadata areas on a PV are ignored, LVM will not store\n"
+	"metadata in them.\n"
+	"The '--metadataignore' option overrides this setting.\n")
 
-cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_BOOL, DEFAULT_PVMETADATAIGNORE, vsn(2, 2, 69), NULL)
 cfg(metadata_stripesize_CFG, "stripesize", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_STRIPESIZE, vsn(1, 0, 0), NULL)
 
 cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0),
@@ -1238,12 +1259,13 @@ cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNS
 cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 
 cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115),
-	"If enabled, fields which don't have value set for any of the rows\n"
-	"reported are skipped on output. Compact output is applicable only\n"
-	"if report is buffered (report/buffered=1).\n")
+	"Do not print empty report fields.\n"
+	"Fields that don't have a value set for any of the rows\n"
+	"reported are skipped and not printed. Compact output is\n"
+	"applicable only if report/buffered is enabled.\n")
 
 cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0),
-	"Align columns on report output.\n")
+	"Align columns in report output.\n")
 
 cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_BUFFERED, vsn(1, 0, 0),
 	"Buffer report output.\n"
@@ -1376,10 +1398,32 @@ cfg(dmeventd_thin_library_CFG, "thin_library", dmeventd_CFG_SECTION, 0, CFG_TYPE
 cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_PATH, vsn(2, 2, 73),
 	"The full path to the dmeventd binary.\n")
 
-cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_HOSTTAGS, vsn(1, 0, 18), NULL)
-
-cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18), NULL)
-cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
+cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_HOSTTAGS, vsn(1, 0, 18),
+	"Create a host tag using the machine name.\n"
+	"The machine name is nodename returned by uname(2).\n")
+
+cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18),
+	"Replace this subsection name with a custom tag name.\n"
+	"Multiple subsections like this can be created.\n"
+	"The '@' prefix for tags is optional.\n"
+	"This subsection can contain host_list, which is a\n"
+	"list of machine names. If the name of the local\n"
+	"machine is found in host_list, then the name of\n"
+	"this subsection is used as a tag and is applied\n"
+	"to the local machine as a 'host tag'.\n"
+	"If this subsection is empty (has no host_list), then\n"
+	"the subsection name is always applied as a 'host tag'.\n"
+	"Example:\n"
+	"The host tag foo is given to all hosts, and the host tag\n"
+	"bar is given to the hosts named machine1 and machine2.\n"
+	"tags { foo { } bar { host_list = [ \"machine1\", \"machine2\" ] } }\n")
+
+cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18),
+	"A list of machine names.\n"
+	"These machine names are compared to the nodename\n"
+	"returned by uname(2). If the local machine name\n"
+	"matches an entry in this list, the name of the\n"
+	"subsection is applied to the machine as a 'host tag'.\n")
 
 cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117),
 	"Defines the local system ID for lvmlocal mode.\n"


