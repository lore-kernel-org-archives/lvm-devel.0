From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 20 Sep 2011 22:01:05 +0200
Subject: [PATCH 8/7][retry remove] Also add check for filesystem use on a DM/LVM device - "dm_device_has_fs"
In-Reply-To: <4E78E64C.8080006@redhat.com>
References: <4E78E64C.8080006@redhat.com>
Message-ID: <4E78F101.7090907@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.9.2011 21:15, Peter Rajnoha napsal(a):
> This is an addition to patch #5 and it adds "dm_device_has_fs" fn to libdm.
> This one gets the kernel device name first by using readlink for
> /sys/dev/major:minor and stripping off the last part of the path which is
> kernel device name actually (we could also use a shortcut here - just assume
> that the kernel name is dm-<minor> but that seems to be less robust for future
> changes). Then we iterate over /sys/fs/ and see if any of the filesystems use
> our DM device (so checking the /sys/fs/<fs_name>/<kernel_dev_name> presence).
> 
> This way, we can tell the user whether a device is opened by another device or
> if it is a filesystem that is still used (iow it's mounted) on a device when
> trying to remove it and unable to do so.
> 
> So we can catch two of three possible reasons for the device removal failure
> which could end up with "device or resource busy" error. The third one which
> we do not handle is "device opened by an application". For this one, we use
> the remove retry logic.
> 
> (Hmm, maybe we could store the sysfs path + kernel_device name somewhere in LVM
> structs so we don't need to repeat those dm_snprintf calls to construct it
> anytime we need to do these checks.)


I'm not a big fan of this patch - it seems to add some strange internal
behavior (i.e. for now weird timing in teardown code)

How bad would be to replace the code in lvremove with something like:
when remove fails -  call  system("udevadm settle") - and retry whole
lv_remove_with_depenencies() (or whatever baselevel we pick here).

If we are adding this retry mainly for udev - we should use udevadm tool to
get the 'optimal' (well I know...) perfomance here.

Current version of code seems to be well hiding missing synchronization points
when we need to wait for udev to finish its processing.

Zdenek

PS: easiest workaround for failing lvremove is - to replace  lvremove with
shell wrapper which call udevadm settle and retries lvremove in case the first
one fails.


