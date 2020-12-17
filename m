From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Thu, 17 Dec 2020 01:32:44 -0000
Subject: [PATCH] dev_name(): add to judge whether the dev->aliases list is empty
In-Reply-To: <61d26ea0-0e02-3384-e5c7-f8e1ae5b35cd@redhat.com>
References: <4f9d1853-8980-511e-3431-c0d549b18a5f@huawei.com>
	<61d26ea0-0e02-3384-e5c7-f8e1ae5b35cd@redhat.com>
Message-ID: <6abd5495-4498-e5cd-f8fa-0028420eb841@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

The LVM version we currently use is 2.02.187, and there is still lvmetad.
We added a print log to lvmetad_pvscan_single and called the dev_name function,
and then triggered the following segmentation fault.


Program terminated with signal SIGSEGV, Segmentation fault.
#0  strlen () at ../sysdeps/aarch64/strlen.S:94
94		ldp	data1, data2, [srcin]
(gdb) bt
#0  strlen () at ../sysdeps/aarch64/strlen.S:94
#1  0x0000ffffa4de5ae0 in _IO_vfprintf_internal (s=0xaaaae1ce7e20, format=0xaaaad282e0b8 "No PV info found on %s for PVID %s.", ap=...) at vfprintf.c:1638
#2  0x0000ffffa4e7e790 in ___vfprintf_chk (fp=fp at entry=0xaaaae1ce7e20, flag=flag at entry=1, format=format at entry=0xaaaad282e0b8 "No PV info found on %s for PVID %s.", ap=...) at vfprintf_chk.c:40
#3  0x0000aaaad273df48 in vfprintf (__ap=..., __fmt=0xaaaad282e0b8 "No PV info found on %s for PVID %s.", __stream=0xaaaae1ce7e20) at /usr/include/bits/stdio2.h:130
#4  _vprint_log (level=<optimized out>, level at entry=65540, file=file at entry=0xaaaad282c780 "cache/lvmetad.c", line=line at entry=2308, dm_errno_or_class=dm_errno_or_class at entry=0,
    format=format at entry=0xaaaad282e0b8 "No PV info found on %s for PVID %s.", orig_ap=...) at log/log.c:633
#5  0x0000aaaad273e380 in print_log (level=level at entry=65540, file=file at entry=0xaaaad282c780 "cache/lvmetad.c", line=line at entry=2308, dm_errno_or_class=dm_errno_or_class at entry=0,
    format=format at entry=0xaaaad282e0b8 "No PV info found on %s for PVID %s.") at log/log.c:726
#6  0x0000aaaad27afde4 in lvmetad_pvscan_single (cmd=cmd at entry=0xaaaae1ce2420, dev=dev at entry=0xaaaae1e38460, found_vgnames=found_vgnames at entry=0xffffc32f3568, changed_vgnames=changed_vgnames at entry=0xffffc32f3588)
    at cache/lvmetad.c:2308
#7  0x0000aaaad26e2bc0 in _pvscan_cache (argv=<optimized out>, argc=<optimized out>, cmd=0xaaaae1ce2420) at pvscan.c:693
#8  pvscan (cmd=0xaaaae1ce2420, argc=<optimized out>, argv=<optimized out>) at pvscan.c:834
#9  0x0000aaaad26d8378 in lvm_run_command (cmd=cmd at entry=0xaaaae1ce2420, argc=<optimized out>, argc at entry=5, argv=<optimized out>, argv at entry=0xffffc32f3a10) at lvmcmdline.c:3010
#10 0x0000aaaad26d9430 in lvm2_main (argc=5, argv=0xffffc32f3a10) at lvmcmdline.c:3539
#11 0x0000ffffa4dbef40 in __libc_start_main (main=0x0, argc=0, argv=0x0, init=<optimized out>, fini=<optimized out>, rtld_fini=<optimized out>, stack_end=<optimized out>) at ../csu/libc-start.c:308
#12 0x0000aaaad26b6f94 in _start ()


int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
			  struct dm_list *found_vgnames,
			  struct dm_list *changed_vgnames)
{
	struct label *label;
	struct lvmcache_info *info;
	struct _lvmetad_pvscan_baton baton;
	const struct format_type *fmt;
	/* Create a dummy instance. */
	struct format_instance_ctx fic = { .type = 0 };

	log_debug_lvmetad("Scan metadata from dev %s", dev_name(dev));

	if (!lvmetad_used()) {
		log_error("Cannot proceed since lvmetad is not active.");
		return 0;
	}

	if (udev_dev_is_mpath_component(dev)) {
		log_debug("Ignore multipath component for pvscan.");
		return 1;
	}

	label_read(dev);
	if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
		log_print_unless_silent("No PV info found on %s for PVID %s.", dev_name(dev), dev->pvid[0] ? dev->pvid : "");	// the print function we added
		if (!lvmetad_pv_gone_by_dev(dev))
			goto_bad;
		return 1;
	}
	...


? 2020/12/16 20:07, Zdenek Kabelac ??:
> Dne 16. 12. 20 v 10:35 Wu Guanghao napsal(a):
>> If dev->aliases linked list is empty, then directly obtain the str address
>> of dm_str_list saved in dev->aliases.n, an unknown address will be returned,
>> which may cause segfault
>>
> 
> Hi
> 
> 
> Do you have a triggering example case ?
> 
> It seems to me this patch is just hiding bug from other place.
> 
> Eventually try to pick-up info how you were able to hit this
> coredump.
> 
> Zdenek
> 
>> Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
>> ---
>> ? lib/device/dev-cache.c | 4 ++--
>> ? 1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
>> index d5f18ff..9441924 100644
>> --- a/lib/device/dev-cache.c
>> +++ b/lib/device/dev-cache.c
>> @@ -1629,8 +1629,8 @@ int dev_fd(struct device *dev)
>>
>> ? const char *dev_name(const struct device *dev)
>> ? {
>> -??? return (dev && dev->aliases.n) ? dm_list_item(dev->aliases.n, struct dm_str_list)->str :
>> -??????? unknown_device_name();
>> +??? return (dev && dev->aliases.n && !dm_list_empty(&dev->aliases)) ? \
>> +??????? dm_list_item(dev->aliases.n, struct dm_str_list)->str : unknown_device_name();
>> ? }
>>
>> ? bool dev_cache_has_md_with_end_superblock(struct dev_types *dt)
>>
> 
> .



