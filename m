From: Petr Rockai <prockai@redhat.com>
Date: Wed, 30 Sep 2009 22:50:12 +0200
Subject: [RFC][PATCH 0/5] dmeventd device filtering
In-Reply-To: <4AC2A616.9060705@redhat.com> (Takahiro Yasui's message of "Tue, 
	29 Sep 2009 20:28:06 -0400")
References: <4AC2A616.9060705@redhat.com>
Message-ID: <874oqkdunv.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui <tyasui@redhat.com> writes:

> BACKGROUND
Agreed.

> SOLUTION
> ========
>
> Device filtering feature is added to dmeventd so that dmeventd calls
> a LVM command with a filter option to limit accessing devices as follows:
>
>    - Allow access to devices associated with the volume group
>    - Deny access to the failed devices which triggered the error recovery
>
> For example, when mimage0 broke in the following environment, the current
> implementation accesses all devices (pv0 ... pv8), but access to pv1 and
> pv2 are enough to remove mimage0.
>
>     vg0 { pv0, pv1, pv2 }, vg1 { pv3, pv4, pv5 }, vg2 { pv6, pv7, pv8 }
>
>         lv0(mirror) --+-- mimage0 { pv0 }
>                       +-- mimage1 { pv1 }
>                       +-- mlog    { pv2 }
>
> This patch set limits devices to be accessed during error recovery.
Interesting idea.

> DESIGN OVERVIEW
> ===============
>
> The key idea is executing lvconvert and vgreduce with "filter" options
> from dmeventd and override filtering rule defined in the config file
> (lvm.conf). When an error is reported to dmeventd, dmeventd automatically
> generates filtering option and call lvm commands with it as follows.
>
>    vgreduce --removemissing --config \
>      devices{filter=["a|/dev/sda", "a|/dev/sdb", ...,"r|.*|"]} VG/LV
>
Sounds like a good interim solution. Eventually, we may want to switch away
from using lvm2cmd for dmeventd plugins, but I agree that this is still far on
the horizon.

> To generate filter option, dmeventd requires a list of devices included
> in the VG. When a LV is registered as a monitoring device, a device list
> of the VG are passed to dmeventd. This information needs to be updated if
> the VG structure is changed by adding or removing devices to/from the VG
> by vgextend, vgreduce or other lvm commands, dmeventd gets a new device
> list.
>
> A failed device list is generated when an error is notified. dmeventd gets
> devices included in failed mirror leg or log from kernel through device-mapper
> interface.
Hmm. Does this introduce some race conditions? When a bad sequence of metadata
edits and failures happens, could this lead to bad behaviour? I have skimmed
the patches and I think following may happen:

- vgextend a volume group (adding say /dev/sde)
- metadata is written and committed
- dmeventd notices a failure, but its device list is out of date 
- lvconvert does its job, but when writing metadata, it marks the /dev/sde PV
  as missing, since it can't find it
- dmeventd triggers vgreduce, which removes /dev/sde from the volume group

It is not a fatal problem, but definitely surprising. Maybe we could fix it,
although I'm not entirely sure how.

Also, I'm a little worried that this is something that may rather easily go out
of sync -- keeping a cached copy of data like this around is always
dangerous. Fortunately, the worst that should happen is that an automatic
recovery fails or that empty PVs are removed from the volume group (like above)
-- it shouldn't be possible to trick dmeventd into clobbering any data this
way. Either way -- I am not sure it is a showstopper, but it's definitely not
very nice. Thoughts?

Yours,
   Petr.

PS: Another thing crossed my mind -- how safe it is to use device node names
here? Would it make more sense to use major/minor numbers? If device nodes get
re-arranged between registration and a failure, this could cause some woes as
well. The gap could easily be many months. Maybe not likely, but definitely not
impossible...


