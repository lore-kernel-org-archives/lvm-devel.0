From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 09 Oct 2012 18:06:04 -0500
Subject: [PATCH]: Add new configurable to allow metadata changes when PVs are missing
Message-ID: <1349823964.32340.2.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch and description follow...
 brassow

config:  Add configurable to allow metadata changes when PVs are missing

A while back the behavior of LVM changed from allowing metadata changes
when PVs were missing to not allowing changes.  Until recently, this
change was tolerated by HA-LVM by forcing a 'vgreduce --removemissing'
before trying (again) to add tags to an LV and then activate it.  LVM
mirroring requires that failed devices are removed anyway, so this was
largely harmless.  However, RAID LVs do not require devices to be removed
from the array in order to be activated.  In fact, in an HA-LVM
environment this would be very undesirable.  Device failures in such an
environment can often be transient and it would be much better to restore
the device to the array than synchronize an entirely new device.

There are two methods that can be used to setup an HA-LVM environment:
"clvm" or "tagging".  For RAID LVs, "clvm" is out of the question because
RAID LVs are not supported in clustered VGs - not even in an exclusively
activated manner.  That leaves "tagging".  HA-LVM uses tagging - coupled
with 'volume_list' - to ensure that only one machine can have an LV active
at a time.  If updates are not allowed when a PV is missing, it is
impossible to add or remove tags to allow for activation.  This removes
one of the most basic functionalities of HA-LVM - site redundancy.  If
mirroring or RAID is used to replicate the storage in two data centers
and one of them goes down, a server and a storage device are lost.  When
the service fails-over to the alternate site, the VG will be "partial".
Unable to add a tag to the VG/LV, the RAID device will be unable to
activate.

The solution is to create a configurable, "handles_missing_pvs", that
allows for the old behavior.  Like 'metadata_read_only' it comes with
a stern warning that "inappropriate use could mess up your system".
The controled environment of HA-LVM is a sufficiently appropriate use
for such a tool and allows for RAID LVs to be used in an HA-LVM
environment.

Index: lvm2/doc/example.conf.in
===================================================================
--- lvm2.orig/doc/example.conf.in
+++ lvm2/doc/example.conf.in
@@ -446,6 +446,13 @@ global {
     # Inappropriate use could mess up your system, so seek advice first!
     metadata_read_only = 0
 
+    # If set to 1, operations that change on-disk metadata will be permitted.
+    #  One particularly useful application is to perform an 'addtag' to enable
+    #  the activation of a partial LV that may be under the control of
+    #  'volume_list' restrictions.
+    # Inappropriate use could mess up your system, so seek advice first!
+    handles_missing_pvs = 0
+
     # 'mirror_segtype_default' defines which segtype will be used when the
     # shorthand '-m' option is used for mirroring.  The possible options are:
     #
Index: lvm2/lib/config/defaults.h
===================================================================
--- lvm2.orig/lib/config/defaults.h
+++ lvm2/lib/config/defaults.h
@@ -49,6 +49,7 @@
 #define DEFAULT_PRIORITISE_WRITE_LOCKS 1
 #define DEFAULT_USE_MLOCKALL 0
 #define DEFAULT_METADATA_READ_ONLY 0
+#define DEFAULT_HANDLES_MISSING_PVS 0
 #define DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH 0
 
 #define DEFAULT_MIRROR_SEGTYPE "mirror"
Index: lvm2/tools/lvmcmdline.c
===================================================================
--- lvm2.orig/tools/lvmcmdline.c
+++ lvm2/tools/lvmcmdline.c
@@ -988,7 +988,9 @@ static void _apply_settings(struct cmd_c
 	cmd->fmt = get_format_by_name(cmd, arg_str_value(cmd, metadatatype_ARG,
 				      cmd->current_settings.fmt_name));
 
-	cmd->handles_missing_pvs = 0;
+	cmd->handles_missing_pvs =
+		find_config_tree_int(cmd, "global/handles_missing_pvs",
+				     DEFAULT_HANDLES_MISSING_PVS);
 }
 
 static const char *_copy_command_line(struct cmd_context *cmd, int argc, char **argv)



