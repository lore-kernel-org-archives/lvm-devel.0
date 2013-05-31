From: Brassow Jonathan <jbrassow@redhat.com>
Date: Fri, 31 May 2013 09:36:37 -0500
Subject: [PATCH] DM RAID: Add ability to throttle sync operations for RAID LVs.
In-Reply-To: <51A852F9.2080208@redhat.com>
References: <1369948507.8964.3.camel@f16> <51A852F9.2080208@redhat.com>
Message-ID: <B9A5B415-4C73-4904-A4DC-98F8F0CB27E2@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On May 31, 2013, at 2:36 AM, Zdenek Kabelac wrote:

> Dne 30.5.2013 23:15, Jonathan Brassow napsal(a):
>> Please take a look at the following patch that adds throttling for RAID
>> sync operations.  Any feedback on what the 'lvs' header should look like
>> when reporting the min/max recovery rate would be helpful also.  (Right
>> now it is MinSync and MaxSync.)
>> 
>>  brassow
>> 
>> 
>> This patch adds the ability to set the minimum and maximum I/O rate for
>> sync operations in RAID LVs.  The options are available for 'lvcreate' and
>> 'lvchange' and are as follows:
>>   --minrecoveryrate <Rate>
>>   --maxrecoveryrate <Rate>
>> The rate is specified in kiB/sec/disk.  Setting the rate to 0 removes the
>> preference.
>> 
> 
> Patch seems to be missing  libdm API extension to set min/max rates.

I had already put those in previously - see 'dm_tree_node_raid_params' and 'dm_tree_node_add_raid_target_with_params()'.

> 
> Maybe the argument for min/max should be specified in 'size' units/second.
> So you could easily say   1M   - just like with other args where we give size.

That sounds like a good idea.

> 
> 
>> +.RB [ \-\-maxrecoveryrate " " \fIRate\fP ]
>> +.RB [ \-\-minrecoveryrate " " \fIRate\fP ]
> 
> .RB [ \-\-minrecoveryrate
> .IB Rate ]

Ok, will do.

 brassow


