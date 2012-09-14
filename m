From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 14 Sep 2012 09:14:38 +0200
Subject: master - systemd: depend on systemd-udev-settle unit in activation unit
In-Reply-To: <20120913181259.GE5883@nostromo.devel.redhat.com>
References: <20120912093754.2FED74B0E@hosted02.fedoraproject.org>
	<50506DDA.10703@redhat.com> <50507399.3010100@redhat.com>
	<20120912151945.GC3870@nostromo.devel.redhat.com>
	<5051A1EE.2040309@redhat.com>
	<20120913181259.GE5883@nostromo.devel.redhat.com>
Message-ID: <5052D95E.5030002@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/13/2012 08:12 PM, Bill Nottingham wrote:
> The problem with the module being gone (as I understand it) is
> that systemd-udev-settle doesn't replace it. Before, the sequence was:
> 
> - udev starts
> - udev loads stuff
> - udev-settle, waits until all the loading of stuff is processed
> - scsi_wait_scan loads
> - ... waits for background scans to finish ...

I assume there are still udev events generated as these devices are being
discovered. So even with scsi_wait_scan, we could end with scsi_wait_scan
done, but events still being processed by udev in userspace(?).
Shouldn't there be this sequence:
    - udev starts
    - udev loads stuff
    - udev-settle
    - scsi_wait_scan
 ---> udev-settle <---

> - can continue with LVM or whatever activation
> 
> The removal of scsi_wait_scan doesn't actually mean any of the bus scans are
> done when you wait on systemd-udev-settle, so making that change won't
> really solve the issue you need. If I'm understanding it right, I think

...sure, udev-settle *does not* solve the background scsi scan.

> in a world without scsi-wait-scan, you're likely going to need to enable
> lvmetad and do incremental activation to have thigns work properly.
> 

Yes, we're hardening lvmetad at the moment to make it enabled by
default and use it as a primary source of metadata information,
where the initial scan done on the devices is based on udev events
that update the lvmetad itself. So LVM is finally going to be fully
event-based.

That's exactly where we're heading actually...

Peter


