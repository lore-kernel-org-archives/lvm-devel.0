From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 27 May 2009 08:01:09 -0400 (EDT)
Subject: Re: [PATCH] Fix handling of snapshots with virtual origin.
In-Reply-To: <4A1D2438.6070500@redhat.com>
References: <4A1C2FFF.8050604@redhat.com>
	<Pine.LNX.4.64.0905270711490.29054@hs20-bc2-1.build.redhat.com>
	<4A1D2438.6070500@redhat.com>
Message-ID: <Pine.LNX.4.64.0905270759310.4445@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Wed, 27 May 2009, Milan Broz wrote:

> Mikulas Patocka wrote:
> > It fixes the problem, but here is another one:
> > 
> > [gerlinda:~]# rmmod dm_zero
> > [gerlinda:~]# lvcreate -n vo -s --virtualoriginsize 64M -L 24M vg1
> >   Can't expand LV vo_vorigin: zero target support missing from kernel?
> >   Couldn't create virtual origin for LV vo
> 
> That's common problem for all target modules when missing, the automatic
> module loading doesn't work and dm_zero is not loaded by default in RHEL btw.
> (mirror and snapshpot is loaded in initrd).

Creating snapshot without dm_snapshot.ko being loaded works in my system. 
It just loads the dm_snapshot module. dm_zero isn't automatically loaded.

This is a trace for attempting to create zero lvm (without any snapshots):

#lvmcmdline.c:986         Processing: lvcreate -vvvv --type zero -L 16M -n z2 vg1
#lvmcmdline.c:989         O_DIRECT will be used
#config/config.c:950       Setting global/locking_type to 1
#locking/locking.c:230       File-based locking selected.
#config/config.c:927       Setting global/locking_dir to /var/lock/lvm
#activate/activate.c:363       Getting target version for zero
#ioctl/libdm-iface.c:1672         dm version   OF   [16384]
#ioctl/libdm-iface.c:1672         dm versions   OF   [16384]
#lvcreate.c:445   zero: Required device-mapper target(s) not detected in your kernel
  Run `lvcreate --help' for more information.

Mikulas


