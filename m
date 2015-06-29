From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 29 Jun 2015 10:02:20 -0400
Subject: udev cookie on DM_DEVICE_RELOAD
In-Reply-To: <55914C1C.6050309@suse.de>
References: <55914C1C.6050309@suse.de>
Message-ID: <20150629140220.GA1604@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jun 29 2015 at  9:46am -0400,
Hannes Reinecke <hare@suse.de> wrote:

> Hi all,
> 
> I've been debugging weird failures in multipathing, where 'multipath
> -r' would occasionally incide libdevmapper to create
> device nodes under /dev/mapper on it's own, instead of relying on
> udev for doing so.
> Looking in the logs, I've found:
> 
> Jun 29 15:15:05 | libdevmapper: ioctl/libdm-iface.c(1725): dm reload
> 3600508b4000cf1c300008000002b0000  NF   [16384] (*1)
> Jun 29 15:15:05 | libdevmapper: ioctl/libdm-iface.c(1689): Cookie
> value is not set while trying to call DM_DEVICE_RESUME ioctl.
> Please, consider using libdevmapper's udev synchronisation interface
> or disable it explicitly by calling dm_udev_set_sync_support(0).
> Jun 29 15:15:05 | libdevmapper: ioctl/libdm-iface.c(1691): Switching
> off device-mapper and all subsystem related udev rules. Falling back
> to libdevmapper node creation.
> 
> Okay, that'll explain it.
> Then I've added a cookie to the call of DM_DEVICE_RELOAD, and
> encountered a hang:
> Jun 29 15:41:55 | 3600508b1001047395656543131580001: addmap [0
> 143305920 multipath 1 queue_if_no_path 0 1 1 service-time 0 1 1 104:0 1]
> Jun 29 15:41:55 | libdevmapper: libdm-common.c(2105): Udev cookie
> 0xd4d7246 (semid 6062098) created
> Jun 29 15:41:55 | libdevmapper: libdm-common.c(2125): Udev cookie
> 0xd4d7246 (semid 6062098) incremented to 1
> Jun 29 15:41:55 | libdevmapper: libdm-common.c(1997): Udev cookie
> 0xd4d7246 (semid 6062098) incremented to 2
> Jun 29 15:41:55 | libdevmapper: libdm-common.c(2238): Udev cookie
> 0xd4d7246 (semid 6062098) assigned to RELOAD task(1) with flags
> DISABLE_LIBRARY_FALLBACK (0x20)
> Jun 29 15:41:55 | libdevmapper: ioctl/libdm-iface.c(1725): dm reload
> 3600508b1001047395656543131580001  NNS    [16384] (*1)
> Jun 29 15:41:55 | libdevmapper: libdm-common.c(2032): Udev cookie
> 0xd4d7246 (semid 6062098) decremented to 1
> Jun 29 15:41:55 | libdevmapper: libdm-common.c(2288): Udev cookie
> 0xd4d7246 (semid 6062098) waiting for zero
> (hangs)
> 
> So apparently you can only set the cookie for DM_DEVICE_RESUME,
> _not_ DM_DEVICE_RELOAD.
> 
> Which is odd, as DM_DEVICE_RELOAD is the only call I'll ever do;
> apparently it's being translated internally into a
> suspend/reload/resume cycle.
> 
> Shouldn't device-mapper take care of setting the cookie correctly?

This is really a question for the lvm2 developers (Alasdair and Peter
Rajnoha specifically, cc'd).


