From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 11 Feb 2009 08:32:56 -0500
Subject: lvm2: warning after mirrored LV is initialized as PV
In-Reply-To: <20090211054908.GA23806@us.ibm.com>
References: <49924582.3040708@redhat.com> <20090211054908.GA23806@us.ibm.com>
Message-ID: <4992D388.90405@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

malahal at us.ibm.com wrote:
> Takahiro Yasui [tyasui at redhat.com] wrote:
>> Jonathan Brassow wrote (in dm-devel)
>>> Note that once you get #1 done you /should/ be able to get a mirrored  
>>> log by:
>>> prompt> lvcreate -m1 --mirrorlog core -l 1 -n mirrored_log vg
>>> prompt> lvcreate -m1 -L 5G -n mirror vg /dev/sdb /dev/sdc /dev/vg/ 
>>> mirrored_log
>> I'm now evaluating the layered LV approach, which was suggested by Jon,
>> with the latest LVM command (2.02.45), but some warning messages are
>> displayed after mirrored LV was initialized as PV.
> 
> Jonathan and Alasdair explained what they mean by 'generic layering' in
> one of the DM/multipath Monday meetings.  Currently allocations are done
> from PV's. They want to include LV's in the allocation map. This
> requires changes in the allocation path. We probably want to designate
> these LVs to avoid admin mistakes. With the above changes in place, we
> don't need to include LVs as PVs at all.
>
...
> If you don't include LVs as PVs, you don't get any warnings you listed!

Thank you for the explanation. I misunderstood their comments. So in
'generic layering', LVs works like physical PVs without creating PV
from LV with pvcreate command, and we don't encounter this warning.

Thanks,
Taka


