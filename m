From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 30 Sep 2023 16:03:09 +0200
Subject: dmeventd is not respecting /etc/lvm/devices/system.devices
In-Reply-To: <20230929210140.GA28125@redhat.com>
References: <fd47987d-5137-ee79-3e81-2c3228f2c9b3@ewheeler.net>
 <20230929210140.GA28125@redhat.com>
Message-ID: <02883eeb-d5c3-486a-a5fb-084b51f9b751@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29. 09. 23 v 23:01 David Teigland napsal(a):
> On Fri, Sep 29, 2023 at 12:18:07PM -0700, Eric Wheeler wrote:
>> Hello all,
>>
>> I am not sure how to resolve the dmeventd warning below, maybe you can
>> help. It appears that dmeventd is finding PVs attached to VMs, but those
>> volumes are not listed in /etc/lvm/devices/system.devices so, presumably,
>> they should be ignored by dmeventd.
> Thanks for bringing his up, it's a neglected and hidden corner of the
> devices file feature that's not well developed.
>
> The existing solution to this problem isn't great, but should work: create
> /etc/lvm/devices/dmeventd.devices, where dmeventd.devices contains devs
> for any VG where dmeventd is needed.  That might be the same as
> system.devices (you could just copy system.devices to dmeventd.devices.)
> If you don't actually need dmeventd, then dmeventd.devices could be empty,
> or better just disable that service.
>
> Without a dmeventd.devices file, dmeventd does not use any devices file
> and looks at all PVs on the system, as you've seen.  This was a quick way
> get around the fact that multiple devices files can be used, but dmeventd
> needs to service all of them.  It turns out multiple devices files aren't
> really used by anyone, as far as I can tell (at least not yet.)  The
> default should be for dmeventd to use system.devices, I expect we can make
> that change for the next release.
>
>> We used to use `global_filter` and that worked fine, but that seems to be
>> deprecated starting in el9 in favor of system.devices. If we try to enable
>> the filters in lvm.conf, then pvs/lvs/vgs commands complain about the
>> filter options being used together with `use_devicesfile=1`. Note that we
>> have PVs on LVs for ssd allocation to different VGs, so `scan_lvs=1` is
>> enabled.  (Maybe turning off scan_lvs would "fix" dmeventd, but I can't
>> test that because we need PVs on LVs for this deployment.)
> I don't think scan_lvs will have any impact on this.
>
>> Aug 28 15:25:29 hv1.ewheeler.net dmeventd[886522]: WARNING: VG name data is used by VGs pcqIki-TjE0-iFMN-D8MH-19Er-ypSm-djfl5D and 9UEiuo-DYzj-UTLi-XYCi-KiBO-wQi2-w5QUtX.
> It's always been difficult to know what dmeventd is doing, and I wonder
> what it's running so frequently.


The usage of dmeventd plugins are quite simply to trace with -fldddd.

In most cases when the plugins 'triggering' condition is met - the action 
happens - typically a call of? a basic lvm command - i.e

when?? monitoring of device discovers a jump in? usage percentage?? say from? 
65%-> 70%? we? call?? 'lvextend --use-policies'

Such command can now likely by modified to? use?? --devicesfile option? - so 
it should not need any read of devices file.

However we need to? resolve all cases where we basically allow to change? VG - 
as that would need to communitcate with dmeventd and update such command.

(We already do want this enhancement anyway - we have RFE to handle? i.e. 
vgextend logic to propagate to dmeventd)


Zdenek


