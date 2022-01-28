From: Martin Wilck <mwilck@suse.com>
Date: Fri, 28 Jan 2022 16:57:57 +0100
Subject: [PATCH] udev: create symlinks and watch even in suspended state
In-Reply-To: <10ad6fc0-6c24-c98b-4a02-2140883af72d@gmail.com>
References: <20220128134229.1783-1-mwilck@suse.com>
	<10ad6fc0-6c24-c98b-4a02-2140883af72d@gmail.com>
Message-ID: <a1f472a89e9825f90a4104bea535086f0cde6b93.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2022-01-28 at 16:33 +0100, Zdenek Kabelac wrote:
> Dne 28. 01. 22 v 14:42 mwilck at suse.com?napsal(a):
> > From: Martin Wilck <mwilck@suse.com>
> > 
> > If a dm device is suspended, we can't run blkid on it. But earlier
> > rules (e.g. 11-dm-parts.rules) might have imported previously
> > scanned
> > properties from the udev db, in particular if the device had been
> > correctly
> > set up beforehand (DM_UDEV_PRIMARY_SOURCE_FLAG==1). Symlinks for
> > existing
> > ID_FS_xyz properties must be preserved in this case. Otherwise
> > lower-priority
> > devices (such as multipath components) might take over the symlink
> > temporarily.
> > 
> > Likewise, we should't stop watching a temporarily suspended, but
> > previously
> > correctly configured dm device.
> 
> 
> I'm a bit confused here what is the purpose of this patch.
> 
> blkid is supposed to scan 'every' disk it's told to scan -? if device
> is 
> suspend - blkid shall fait till it's resumed.

Here we're talking about a device that had been successfully scanned
before (during initramfs processing). In my case it was a partition-on-
multipath device (linear mapping on top of multipath mapping) hosting a
btrfs file system with multiple subvolumes. The problem occurs when the
coldplug "add" event is processed after switching to the real root, and
if the device is in suspended state for whatever reason when that
happens. If the SYMLINK+= directive for the /dev/disk/by-uuid link for
the device is skipped in the udev rules, udev will notice and remove
the symlink (which means in the case of multipath: assign it to a
component SCSI device instead).

systemd, however, thinks that the /dev/disk/by-uuid device is ready for
processing and tries to mount it while the symlink wrongly points to
the SCSI device. That fails (the SCSI device is mapped by multipath),
and thus booting fails. See a log excerpt below. 

> Suspend operation itself is meant to be quick - and process
> suspending any 
> device should be doing it rather 'quickly'? (aka reload DM table)
> 
> So now - how do you get 'suspended' devices that are blocking blkid ?

It's a race condition. It probably happens while multipathd is
reloading a map (*), suspending it during the table reload. The device
will be resumed a few fractions of a second later (so yes, it's
"quick"), but then it's too late - systemd will already have tried to
mount it, and failed. When emergency mode is reached, all looks fine,
because the device has been resumed and the correct symlink has been
restored by udev while processing the associated CHANGE event.

I can actually see that some of the subvolumes are mounted successfully
and some are not. It all depends on the timing, which device mount(2)
actually accesses when it follows the by-uuid symlink.



> lvm2 has implemented some sort of 'optional' hack to avoid scanning
> suspended 
> devices - but this shouldn't be normally needed - unless your system
> is flawed 
> with some set of suspended devices (maybe from some crashed lvm
> command).

I'm not sure what "hack" you're talking about. 13-dm-disk.rules always
skips calling "blkid" for suspended devices. And that's correct.
The point is not to "forget" valid symlinks because scanning is
skipped.

Regards
Martin

(*) If a dm device is encountered in such a transient suspended state,
it is very difficult to figure out why / by which process it was
suspended, in particular during boot (tell me if you know a good trick
to figure it out). But multipathd is a likely candidate.

Sample boot log:

> [  127.532674] localhost systemd-udevd[1080]: dm-13: Updating old device symlink '/dev/disk/by-uuid/e40d3005-ab2f-4845-bd83-be5fd09e62a0', which is no longer belonging to this device.
> [  127.532784] localhost systemd-udevd[1080]: dm-13: Found 'b8:18' claiming '/run/udev/links/disk\x2fby-uuid\x2fe40d3005-ab2f-4845-bd83-be5fd09e62a0'
> [  127.533079] localhost systemd-udevd[1080]: sdb2: Device claims priority 0 for '/run/udev/links/disk\x2fby-uuid\x2fe40d3005-ab2f-4845-bd83-be5fd09e62a0'
> [  127.533150] localhost systemd-udevd[1080]: dm-13: Found 'b8:146' claiming '/run/udev/links/disk\x2fby-uuid\x2fe40d3005-ab2f-4845-bd83-be5fd09e62a0'
> [  127.533397] localhost systemd-udevd[1080]: dm-13: Found 'b8:82' claiming '/run/udev/links/disk\x2fby-uuid\x2fe40d3005-ab2f-4845-bd83-be5fd09e62a0'
> [  127.533678] localhost systemd-udevd[1080]: dm-13: Atomically replace '/dev/disk/by-uuid/e40d3005-ab2f-4845-bd83-be5fd09e62a0'
> [  127.535494] localhost systemd[1]: srv.mount: About to execute /usr/bin/mount /dev/disk/by-uuid/e40d3005-ab2f-4845-bd83-be5fd09e62a0 /srv -t btrfs -o subvol=/@/srv
> [  127.535845] localhost systemd[1]: srv.mount: Forked /usr/bin/mount as 1343
> [  127.535992] localhost systemd[1]: srv.mount: Changed dead -> mounting
> [  127.536278] localhost systemd[1343]: srv.mount: Executing: /usr/bin/mount /dev/disk/by-uuid/e40d3005-ab2f-4845-bd83-be5fd09e62a0 /srv -t btrfs -o subvol=/@/srv
> [  127.657542] localhost mount[1343]: mount: /srv: /dev/sdb2 already mounted or mount point busy.
> [  127.888332] localhost systemd[1]: srv.mount: Failed to read oom_kill field of memory.events cgroup attribute: No such file or directory
> [  127.888532] localhost systemd[1]: srv.mount: Child 1343 belongs to srv.mount.
> [  127.888779] localhost systemd[1]: srv.mount: Mount process exited, code=exited, status=32/n/a
> [  127.888961] localhost systemd[1]: srv.mount: Failed with result 'exit-code'.
> [  127.889200] localhost systemd[1]: srv.mount: Changed mounting -> failed
> [  127.890046] localhost systemd[1]: srv.mount: Job 180 srv.mount/start finished, result=failed
> [  127.890283] localhost systemd[1]: Failed to mount /srv.
> [  127.918072] localhost systemd[1]: srv.mount: Unit entered failed state.

Note the message "Updating old device symlink '/dev/disk/by-
uuid/e40d3005-ab2f-4845-bd83-be5fd09e62a0', which is no longer
belonging to this device"), which is where the trouble starts.



