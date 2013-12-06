From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 06 Dec 2013 15:31:58 +0100
Subject: Possibility to convert to exclusive active (opened) volume on clustered VG
In-Reply-To: <52A1DB94.1020001@activecloud.com>
References: <52A14E1A.3030509@activecloud.com> <52A18F2B.5070607@redhat.com>
	<52A1DB94.1020001@activecloud.com>
Message-ID: <52A1DFDE.8050706@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 6.12.2013 15:13, Raman napsal(a):
> Hello,
> On 12/06/2013 11:47 AM, Zdenek Kabelac wrote:
>> Dne 6.12.2013 05:10, Raman napsal(a):
>>> Hello,
>>>
>>> Currently there is no way to convert opened volume from CR to EX or
>>> from EX to CR lock type on clustered volume group. The only way is to
>>> deactivate volume and activate it exclusively again. Example:
>>>
>>> Simple cman cluster:
>>> [root at clvmd2 ~]# cat /etc/cluster/cluster.conf
>>> <?xml version="1.0"?>
>>> <cluster config_version="1" name="clu">
>>>          <clusternodes>
>>>                  <clusternode name="clvmd1" nodeid="1"/>
>>>                  <clusternode name="clvmd2" nodeid="2"/>
>>>          </clusternodes>
>>>          <cman broadcast="yes" port="5501"/>
>>>          <totem token="60000"/>
>>> </cluster>
>>>
>>> Clustered volume group:
>>> [root at clvmd1 ~]# vgs --noheadings
>>>    vg     1   1   0 wz--nc 9.31g 9.21g
>>>
>>> Single volume activated on both nodes:
>>> [root at clvmd1 ~]# lvs --noheadings
>>>    lv1  vg   -wi-a----- 100.00m
>>> [root at clvmd2 ~]# lvs --noheadings
>>>    lv1  vg   -wi-a----- 100.00m
>>>
>>> Deactivating on second node and trying to acquire volume exclusively on
>>> the first node:
>>> [root at clvmd2 ~]# lvchange -aln vg/lv1
>>> [root at clvmd1 ~]# lvchange -ae vg/lv1
>>>    Error locking on node clvmd1: Device or resource busy
>>> [root at clvmd1 ~]#
>>>
>>> But works fine with deactivating cycle:
>>> [root at clvmd1 ~]# lvchange -aln vg/lv1 && lvs --noheading
>>>    lv1  vg   -wi------- 100.00m
>>> [root at clvmd1 ~]# lvchange -ae vg/lv1 && lvs --noheading
>>>    lv1  vg   -wi-a----- 100.00m
>>> [root at clvmd1 ~]#
>>>
>>> Proposed patch tries to solve this problem allowing lock conversion
>>> for activated volumes on clustered volume groups.
>>
>>
>> Patch looks mostly good - but has one 'tiny' problem which is
>> unfortunately not so easy to resolve.
>>
>> +#define LCK_CONVERT    0x00000800U    /* Try lock conversion */
>>
>> I do not know how old code are you are patching - but recent upstream
>> git has this bit already in use:
>>
>> #define LCK_REMOTE    0x00000800U    /* Propagate to remote nodes only */
>>
>>
>> And the protocol is awkward to extend (all bits are already in use).
>>
>> So the question is if we are able to find some bit combination
>> to use it uniquely for activate_lv_excl_local_convert()?
>>
>>
>> Zdenek
>>
>> --
>> lvm-devel mailing list
>> lvm-devel at redhat.com
>> https://www.redhat.com/mailman/listinfo/lvm-devel
>
> My fail.
> LCK_CONVERT can safely use 0x00001000U.
> It used only in "flags" which is uint32_t.
> cman protocol uses already defined LCK_CONVERT_MODE in args[1]
>

Ahh - right - it seems the bit for LCK_CONVERT to be transmited
via '2-byte' message has been actually already reserved,
so it doesn't need extension at this area (which is not really extensible)

So it's not a big issue to extend the lock_lv_vol() flag.

Zdenek




