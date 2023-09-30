From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 30 Sep 2023 15:53:41 +0200
Subject: dmeventd is not respecting /etc/lvm/devices/system.devices
In-Reply-To: <415d2f91-caac-a899-83da-31c12f7c2a6@ewheeler.net>
References: <fd47987d-5137-ee79-3e81-2c3228f2c9b3@ewheeler.net>
 <20230929210140.GA28125@redhat.com>
 <415d2f91-caac-a899-83da-31c12f7c2a6@ewheeler.net>
Message-ID: <4db7fd97-2f0c-48e3-b7c2-43fe6bd662ae@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30. 09. 23 v 2:47 Eric Wheeler napsal(a):
> On Fri, 29 Sep 2023, David Teigland wrote:
>> On Fri, Sep 29, 2023 at 12:18:07PM -0700, Eric Wheeler wrote:
>>> Hello all,
>>>
>>> I am not sure how to resolve the dmeventd warning below, maybe you can
>>> help. It appears that dmeventd is finding PVs attached to VMs, but those
>>> volumes are not listed in /etc/lvm/devices/system.devices so, presumably,
>>> they should be ignored by dmeventd.
>> Thanks for bringing his up, it's a neglected and hidden corner of the
>> devices file feature that's not well developed.
>>
>> The existing solution to this problem isn't great, but should work: create
>> /etc/lvm/devices/dmeventd.devices, where dmeventd.devices contains devs
>> for any VG where dmeventd is needed.  That might be the same as
>> system.devices (you could just copy system.devices to dmeventd.devices.)
>> If you don't actually need dmeventd, then dmeventd.devices could be empty,
> For now we created an empty dmeventd.devices file which seems to do what
> we need.
>
>> or better just disable that service.
> What is the proper way to disable dm-event?  I tried systemctl but it
> barks:
>
> 	# systemctl disable dm-event
> 	The unit files have no installation config (WantedBy=, RequiredBy=, Also=,
> 	Alias= settings in the [Install] section, and DefaultInstance= for template
> 	units). This means they are not meant to be enabled or disabled using systemctl.
> 	
> 	Possible reasons for having this kind of units are:
> 	? A unit may be statically enabled by being symlinked from another unit's
> 	  .wants/ or .requires/ directory.
> 	? A unit's purpose may be to act as a helper for some other unit which has
> 	  a requirement dependency on it.
> 	? A unit may be started when needed via activation (socket, path, timer,
> 	  D-Bus, udev, scripted systemctl call, ...).
> 	? In case of template units, the unit is meant to be enabled with some
> 	  instance name specified.
>
>> Without a dmeventd.devices file, dmeventd does not use any devices file
>> and looks at all PVs on the system, as you've seen.  This was a quick way
>> get around the fact that multiple devices files can be used, but dmeventd
>> needs to service all of them.  It turns out multiple devices files aren't
>> really used by anyone, as far as I can tell (at least not yet.)  The
>> default should be for dmeventd to use system.devices, I expect we can make
>> that change for the next release.
>>
>>> We used to use `global_filter` and that worked fine, but that seems to be
>>> deprecated starting in el9 in favor of system.devices. If we try to enable
>>> the filters in lvm.conf, then pvs/lvs/vgs commands complain about the
>>> filter options being used together with `use_devicesfile=1`. Note that we
>>> have PVs on LVs for ssd allocation to different VGs, so `scan_lvs=1` is
>>> enabled.  (Maybe turning off scan_lvs would "fix" dmeventd, but I can't
>>> test that because we need PVs on LVs for this deployment.)
>> I don't think scan_lvs will have any impact on this.
>>
>>> Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: WARNING: VG name data is used by VGs pcqIki-TjE0-iFMN-D8MH-19Er-ypSm-djfl5D and 9UEiuo-DYzj-UTLi-XYCi-KiBO-wQi2-w5QUtX.
>> It's always been difficult to know what dmeventd is doing, and I wonder
>> what it's running so frequently.
> Thats funny, me too. Your answer definitely sheds some light on the
> situation.  Thanks for the quick response.


Hi


Note - disabling? 'dmeventd'? is likely not a good idea - the reason dmeventd 
is used/started is usually always meaningful.

Typically repair of failing raid arrays,? monitoring and resize of thin-pool 
data & metadata, vdo pool or old thick snapshot.

User of can disable monitoring (and thus all dmeventd usage) by simply 
setting? monitoring=0? in lmv.conf? - but then all the above mentioned 
features are simply gone.

So if there are still some left problem with devices files & dmeventd - we 
need to figure out the solution for them.


Zdenek

