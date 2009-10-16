From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 16 Oct 2009 14:54:00 -0400
Subject: [RFC][PATCH 0/5] dmeventd device filtering
In-Reply-To: <20091007015832.GA9457@us.ibm.com>
References: <4AC2A616.9060705@redhat.com>	<874oqkdunv.fsf@twilight.int.mornfall.net.>
	<20091007015832.GA9457@us.ibm.com>
Message-ID: <4AD8C148.8010303@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/06/09 21:58, malahal at us.ibm.com wrote:
> Petr Rockai [prockai at redhat.com] wrote:
>> Hmm. Does this introduce some race conditions? When a bad sequence of metadata
>> edits and failures happens, could this lead to bad behaviour? I have skimmed
>> the patches and I think following may happen:
>>
>> - vgextend a volume group (adding say /dev/sde)
>> - metadata is written and committed
>> - dmeventd notices a failure, but its device list is out of date 
>> - lvconvert does its job, but when writing metadata, it marks the /dev/sde PV
>>   as missing, since it can't find it
>> - dmeventd triggers vgreduce, which removes /dev/sde from the volume group
>>
>> It is not a fatal problem, but definitely surprising. Maybe we could fix it,
>> although I'm not entirely sure how.
>>
>> Also, I'm a little worried that this is something that may rather easily go out
>> of sync -- keeping a cached copy of data like this around is always
>> dangerous. Fortunately, the worst that should happen is that an automatic
>> recovery fails or that empty PVs are removed from the volume group (like above)
>> -- it shouldn't be possible to trick dmeventd into clobbering any data this
>> way. Either way -- I am not sure it is a showstopper, but it's definitely not
>> very nice. Thoughts?
>>
>> Yours,
>>    Petr.
> 
> How about vgreduce only not scanning the failed devices. It will scan
> /dev/sde in the above case. Multiple device failures at the same (not
> uncommon) is going to be a problem though. :-(

If there is some way to make vgreduce/lvconvert avoid scanning, just
filtering out failed devices would work. Metadata cache feature,

Introduce metadata cache feature
https://www.redhat.com/archives/lvm-devel/2009-April/msg00014.html

or another way like not saving metadata on each device but saving it
in a directory by lvm configuration:

  metadata/pvmetadatacopies=0
  metadata/dirs=[<directory>]

Thanks,
Taka


