From: Nikhil Kshirsagar <nkshirsa@redhat.com>
Date: Sat, 3 Aug 2019 12:56:03 +0530
Subject: lvmcache in writeback mode gets stuck flushing dirtyblocks
In-Reply-To: <CAMNNMLFnGpkFkbDMsO3k_GJKoHLcmk-chn3O6dtBCgyxjrXkwA@mail.gmail.com>
References: <5d3fce60.1c69fb81.f521b.46a8@mx.google.com>
	<CAMNNMLH8jxxRYNyZn6s=Qqhgt7kA5CereTUw8GSNeUrJ5V9iDw@mail.gmail.com>
	<5d41650e.1c69fb81.cd7bd.5ade@mx.google.com>
	<CAMNNMLFnGpkFkbDMsO3k_GJKoHLcmk-chn3O6dtBCgyxjrXkwA@mail.gmail.com>
Message-ID: <CAMNNMLHRjNR71m06pz=uU1OaDeBVh0j+EScBkhSeuDom-Zvurw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Can you try increasing migration threshold through the device mapper
commands and check if this gets rid of the infinite flushes ?

On Fri, 2 Aug, 2019, 5:14 PM Nikhil Kshirsagar, <nkshirsa@redhat.com> wrote:

> Hello,
>
> You are welcome.
>
> The migration threshold is in terms of chunks, I think.. So it should be
> at least one chunk so the looping forever won't happen. The bug we found
> was if chunksize goes beyond a certain value triggered by larger than one
> tb sized cached lv, it ends up with migration threshold hard coded to lower
> than the increased chunksize.
>
> Yes migration threshold right now needs better documentation and
> explanations. Also the ability to see it from lvm commands just like we can
> see chunksize. We are working on it through the bzs mentioned earlier. (See
> the bz about migration threshold needing better documentation in the man
> pages)
>
> I think right now you can get it only at the device mapper layer, will
> check..
>
> Regards,
> Nikhil.
>
>
>
> On Fri, 2 Aug, 2019, 5:09 PM Lakshmi Narasimhan Sundararajan, <
> lns at portworx.com> wrote:
>
>> Hi Nikhil,
>> Thank you for your email. Much appreciated.
>>
>>
>>
>> In my environment, Chunksize is fixed at 1M irrespective of the pool
>> size. This may take the number of entries over 1M and result in kernel
>> warning. But the class of systems we are using are huge, and so the memory
>> and cpu bottlenecks does not seem to be a factor in our testing.
>>
>>
>>
>> I looked up at the bugs. The first one about chunksize > 1M, we should be
>> safe on that given our chunksize is fixed at 1MB.
>>
>> The other one about migration threshold is interesting, I will have to
>> validate this again.
>>
>>
>>
>> What would be the unit of migration threshold?  Is it the number of 512
>> byte sectors? And what exactly is its definition?
>>
>>
>>
>> And also curiously this does not seem to be exported through lvm cli,
>> need to fetch this only through dmsetup?
>>
>>
>>
>> Thanks
>>
>> LN
>>
>> Sent from Mail <https://go.microsoft.com/fwlink/?LinkId=550986> for
>> Windows 10
>>
>>
>>
>> *From: *Nikhil Kshirsagar <nkshirsa@redhat.com>
>> *Sent: *Wednesday, July 31, 2019 3:04 PM
>> *To: *LVM2 development <lvm-devel@redhat.com>
>> *Subject: *Re: [lvm-devel] lvmcache in writeback mode gets stuck
>> flushing dirtyblocks
>>
>>
>>
>> This used to happen if the chunksize increased as a result of needing to
>> use more than a million chunks to store the size of the cached lv. What is
>> the size of the pool?
>>
>>
>>
>> Regards,
>>
>> Nikhil.
>>
>>
>>
>> On Tue, 30 Jul, 2019, 1:25 PM Lakshmi Narasimhan Sundararajan, <
>> lns at portworx.com> wrote:
>>
>> Hi Team,
>>
>> A very good day to all.
>>
>>
>> I am using lvmcache in writeback mode. When there are dirty blocks still
>> in the lv, and if needs to be destroyed or flushed, then
>>
>> It seems to me that there are some conditions under which the dirty data
>> flush gets stuck forever.
>>
>>
>>
>>
>>
>> As an example:
>>
>> root at pdc4-sm35:~# lvremove -f pwx0/pool
>>
>>   367 blocks must still be flushed.
>>
>>   367 blocks must still be flushed.
>>
>>   367 blocks must still be flushed.
>>
>>   367 blocks must still be flushed.
>>
>>   367 blocks must still be flushed.
>>
>>   367 blocks must still be flushed.
>>
>> ^C
>>
>> root at pdc4-sm35:~#
>>
>>
>>
>> I am running these version:
>>
>> root at pdc4-sm35:~# lvm version
>>
>>   LVM version:     2.02.133(2) (2015-10-30)
>>
>>   Library version: 1.02.110 (2015-10-30)
>>
>>   Driver version:  4.34.0
>>
>> root at pdc4-sm35:~#
>>
>>
>>
>>
>>
>> This issue seems old and reported multiple places. There have been some
>> acknowledgement that this issue is resolved in 2.02.133, but still I see
>> it. Also, I have seen some posts report it in 2.02.170+ as well (here:
>> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=878441) (Package: lvm2
>> Version: 2.02.173-1 Severity: normal)
>>
>>
>>
>> I filed one here myself, https://github.com/lvmteam/lvm2/issues/22,
>> trying  to understand from you experts where we are on this?
>>
>>
>>
>> I would sincerely appreciate your help in understanding the state of this
>> issue in more detail.
>>
>>
>>
>> Best regards
>> LN
>>
>> Sent from Mail <https://go.microsoft.com/fwlink/?LinkId=550986> for
>> Windows 10
>>
>>
>>
>> --
>> lvm-devel mailing list
>> lvm-devel at redhat.com
>> https://www.redhat.com/mailman/listinfo/lvm-devel
>>
>>
>> --
>> lvm-devel mailing list
>> lvm-devel at redhat.com
>> https://www.redhat.com/mailman/listinfo/lvm-devel
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190803/5656d0b8/attachment.htm>
