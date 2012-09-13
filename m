From: Bill Nottingham <notting@redhat.com>
Date: Thu, 13 Sep 2012 14:12:59 -0400
Subject: master - systemd: depend on systemd-udev-settle unit in activation unit
In-Reply-To: <5051A1EE.2040309@redhat.com>
References: <20120912093754.2FED74B0E@hosted02.fedoraproject.org>
	<50506DDA.10703@redhat.com> <50507399.3010100@redhat.com>
	<20120912151945.GC3870@nostromo.devel.redhat.com>
	<5051A1EE.2040309@redhat.com>
Message-ID: <20120913181259.GE5883@nostromo.devel.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Peter Rajnoha (prajnoha at redhat.com) said: 
> Yes, you're right... for older systems where this module is still
> present, we should still use the scsi-wait-scan.
> 
> However, this is now (at least in Fedora) maintained under
> our own initscripts which is not present in all distros I guess.
> I'm just trying to point out that it would be better to have
> this "fedora-storage-wait" unit in systemd/udev upstream directly
> and give it a common name like "storage-wait" which other
> storage-related upstream projects could use for reference in
> their systemd units if we want to keep it for backward compatibility.
> 
> But since the module is now gone, I'm inclined to using systemd-udev-settle
> instead and if an update/rebase is needed in packages in older
> distro releases, just providing a simple one line patch attached
> directly to the build (making use of the original fedora-storage-wait.service).

The problem with the module being gone (as I understand it) is
that systemd-udev-settle doesn't replace it. Before, the sequence was:

- udev starts
- udev loads stuff
- udev-settle, waits until all the loading of stuff is processed
- scsi_wait_scan loads
- ... waits for background scans to finish ...
- can continue with LVM or whatever activation

The removal of scsi_wait_scan doesn't actually mean any of the bus scans are
done when you wait on systemd-udev-settle, so making that change won't
really solve the issue you need. If I'm understanding it right, I think
in a world without scsi-wait-scan, you're likely going to need to enable
lvmetad and do incremental activation to have thigns work properly.

Bill


