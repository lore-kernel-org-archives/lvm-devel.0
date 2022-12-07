From: wangzhiqiang (Q) <wangzhiqiang95@huawei.com>
Date: Wed, 7 Dec 2022 09:34:13 +0000
Subject: [PATCH] pvscan --cache /dev/xx needs to scan all disks and aliases when enable device filter
Message-ID: <971ecec87dad4fe2a1771f3c75c5cffb@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When the system restarts and the disk goes online, the udev rule will be triggered to scan the metadata on
the disk to automatically activate the logical volume, If we specify the scanned disk alias in lvm.conf, reject
other unspecified disks, then lv cannot activate since the aliases mismatch with disk name.

If device filtering is configured in lvm.conf, then pvscan --cache /dev/xx needs to scan all disks and aliases

Signed-off-by: wangzhiqiang<wangzhiqiang95@huawei.com>
Signed-off-by: wuguanghao<wuguanghao3@huawei.com>
---
lib/commands/toolcontext.c | 2 ++
lib/commands/toolcontext.h | 1 +
tools/pvscan.c             | 7 +++++++
3 files changed, 10 insertions(+)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4faad0e..900b6ce 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1175,6 +1175,7 @@ static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
                        goto bad;
                }
                nr_filt++;
+               cmd->filter_in_config = 1;
        }

        /* regex filter. Optional. */
@@ -1184,6 +1185,7 @@ static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
                        goto bad;
                }
                nr_filt++;
+               cmd->filter_in_config = 1;
        }

        /* device type filter. Required. */
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 957ab7f..0539122 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -194,6 +194,7 @@ struct cmd_context {
        unsigned filter_deviceid_skip:1;        /* don't use filter-deviceid */
        unsigned filter_regex_with_devices_file:1; /* use filter-regex even when devices file is enabled */
        unsigned filter_nodata_only:1;          /* only use filters that do not require data from the dev */
+       unsigned filter_in_config:1;            /* only use filters set by lvm.conf */
        unsigned run_by_dmeventd:1;             /* command is being run by dmeventd */
        unsigned sysinit:1;                     /* --sysinit is used */
        unsigned ignorelockingfailure:1;        /* --ignorelockingfailure is used */
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 95d593d..19d99b8 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1944,6 +1944,13 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
                        log_verbose("Ignoring pvscan --cache because event_activation is disabled.");
                        return ECMD_PROCESSED;
                }
+
+               /*
+                * scan all dev to avoid mismatch between the drive name and aliases
+                */
+               if (cmd->filter_in_config)
+                       lvmcache_label_scan(cmd);
+
                if (!_pvscan_cache_args(cmd, argc, argv, &complete_vgnames))
                        return ECMD_FAILED;
        }
--
2.33.0

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20221207/69b4e7fc/attachment.htm>
