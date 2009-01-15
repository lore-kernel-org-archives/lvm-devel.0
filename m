From: Bryn M. Reeves <bmr@redhat.com>
Date: Thu, 15 Jan 2009 13:39:07 +0000
Subject: lvresize.c: use kilobytes when passing sizes to fsadm
In-Reply-To: <496F389B.4060603@redhat.com>
References: <496E202C.1060009@redhat.com> <496F389B.4060603@redhat.com>
Message-ID: <496F3C7B.4060102@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz wrote:
> Bryn M. Reeves wrote:
>> The code in lvresize.c computes a new file system size to pass to 
>> fsadm when resizing as (extents * extent_size), giving a result in 
>> kilobytes.
>>
>> This is then passed on to fsadm without a suffix, meaning that fsadm 
>> interprets it as a count of the number of file system blocks instead.
>>
>> This breaks fsadm for all file system block sizes other than 1K.
>>
>> The attached patch adds a "K" suffix and fixes the problem for me - see:
>>
>> https://bugzilla.redhat.com/show_bug.cgi?id=480022
> 
> Reviewed-by: Milan Broz <mbroz@redhat.com>
> Tested-by: Milan Broz <mbroz@redhat.com>
> 

Thanks Milan!

> 
> p.s.
> Jaroslav, please can you add some tests internally for fsadm/lvresize?
> (test in bugzilla, just extend/reduce for 1024,2048,4096 fs blocksize,
> mke2fs -b <bs> is enough (or maybe xfs, reiserfs tests too))

Sorry, I meant to take a look at the test suite yesterday to see if I 
could figure out adding tests for this but ran out of time.

Cheers,
Bryn.


