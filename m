From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 16 Oct 2009 11:46:28 -0400
Subject: [RFC][PATCH 0/5] dmeventd device filtering
In-Reply-To: <874oqkdunv.fsf@twilight.int.mornfall.net.>
References: <4AC2A616.9060705@redhat.com>
	<874oqkdunv.fsf@twilight.int.mornfall.net.>
Message-ID: <4AD89554.6030406@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

>> To generate filter option, dmeventd requires a list of devices included
>> in the VG. When a LV is registered as a monitoring device, a device list
>> of the VG are passed to dmeventd. This information needs to be updated if
>> the VG structure is changed by adding or removing devices to/from the VG
>> by vgextend, vgreduce or other lvm commands, dmeventd gets a new device
>> list.
>>
>> A failed device list is generated when an error is notified. dmeventd gets
>> devices included in failed mirror leg or log from kernel through device-mapper
>> interface.
> Hmm. Does this introduce some race conditions? When a bad sequence of metadata
> edits and failures happens, could this lead to bad behaviour? I have skimmed
> the patches and I think following may happen:
> 
> - vgextend a volume group (adding say /dev/sde)
> - metadata is written and committed
> - dmeventd notices a failure, but its device list is out of date 
> - lvconvert does its job, but when writing metadata, it marks the /dev/sde PV
>   as missing, since it can't find it
> - dmeventd triggers vgreduce, which removes /dev/sde from the volume group
> 
> It is not a fatal problem, but definitely surprising. Maybe we could fix it,
> although I'm not entirely sure how.
> 
> Also, I'm a little worried that this is something that may rather easily go out
> of sync -- keeping a cached copy of data like this around is always
> dangerous. Fortunately, the worst that should happen is that an automatic
> recovery fails or that empty PVs are removed from the volume group (like above)
> -- it shouldn't be possible to trick dmeventd into clobbering any data this
> way. Either way -- I am not sure it is a showstopper, but it's definitely not
> very nice. Thoughts?

I'm very sorry for my late response. You are right. This method needs to keep 
data integrity between dmeventd and lvm metadata on disk and the sequence you
described should be handled in some way.

I don't have perfect solution right now, but stopping monitoring during VG
update would be one of the solutions. Stopping and starting monitoring is
not a perfect solution, but it is the same as LV is changed. Anyway, I will
look into solutions, and I appreciate if you could give me some idea.

> PS: Another thing crossed my mind -- how safe it is to use device node names
> here? Would it make more sense to use major/minor numbers? If device nodes get
> re-arranged between registration and a failure, this could cause some woes as
> well. The gap could easily be many months. Maybe not likely, but definitely not
> impossible...

I understand your point. It is not impossible but it is not likely. I believe
it is the base idea on which the current filtering method or device-cache
are implemented.

Thanks,
Taka


