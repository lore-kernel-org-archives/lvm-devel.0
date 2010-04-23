From: brem belguebli <brem.belguebli@gmail.com>
Date: Fri, 23 Apr 2010 18:01:19 +0200
Subject: [BUG-REPORT] mirror legs in the same PV with --alloc anywhere
In-Reply-To: <s2q29ae894c1004211036i8113a0e4q16670c46f5700bf1@mail.gmail.com>
References: <4BC7817E.7080407@redhat.com>
	<20100415220308.GO13021@agk-dp.fab.redhat.com>
	<4BC88002.10803@redhat.com> <1271495752.5449.53.camel@localhost>
	<4BCF1761.7080805@redhat.com>
	<s2q29ae894c1004211036i8113a0e4q16670c46f5700bf1@mail.gmail.com>
Message-ID: <t2i29ae894c1004230901qe3e4fa75of26e8d39e0d8c7cd@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I've read in the RHEL 5.5 technical datasheet that the shipped LVM
version 2.02.56 was alraedy capable of mirrored log.

Do you confirm that , as both the man pages (lvcreate, etc...) and the
lvcreate -h do not show the option to do so.

Regards

Brem

2010/4/21 brem belguebli <brem.belguebli@gmail.com>:
> Yes, Thanks.
>
> Mirrored-log allocated right on the 2 (or more) PV legs is something
> we've been expecting for long now, and I'm sure I'm not the only one
> in this case.
>
> We had to hack-build our mirrored disks by layering MD over LVM, which
> is not that friendly in terms of integration, MD not being
> device-mapper friendly (it may have changed now) and in terms of
> debugging it's not always easy.
>
> Hope you'll get it right, that'll make a lot of people life easier.
>
> Brem
>
> 2010/4/21 Takahiro Yasui <tyasui@redhat.com>:
>> On 04/17/10 05:15, brem belguebli wrote:
>>> I think things are not clear about this one, and everyone is confused.
>>
>> I believe that we agreed on what was our goal through this thread.
>>
>>> Malahal (from IBM) and you have posted a few weeks ago design proposals
>>> and patches to add mirrored log capabilities and also the fact that it
>>> could be located on the mirror legs (pv in our cases) by using
>>> alloc_anywhere.
>>>
>>> alloc_anywhere, as described in the man page is to let LVM put the data
>>> logical extents where ever it wants (not strict allocation policy) which
>>> is, in case a mirror is expected completely a nonsense.
>>
>> Yes, you are right. We can't expect where logical extents are
>> allocated for '--alloc anywhere'
>>
>>> You may, (this is a suggestion), when lvcreating a mirror with
>>> mirrored-log
>>> - force strict allocation for the LE's (otherwise it' nonsense)
>>> - put the mirrored log leg on each PV
>>> - And may be disable alloc anywhare when creating mirrors ?
>>
>> I think that 'mirrored log' capability is very useful and enhancing
>> availability is our next step. It is helpful if users can directly
>> build a mirror volume, which has a mirrored log and is built on two
>> physical devices and also each physical device contains a mirror
>> leg and a mirror log, by a simple command line.
>>
>> I hope this explanation would be helpful.
>>
>> Thanks,
>> Taka
>>
>> --
>> lvm-devel mailing list
>> lvm-devel at redhat.com
>> https://www.redhat.com/mailman/listinfo/lvm-devel
>>
>


