From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 14 Aug 2017 14:36:34 +0200
Subject: Batch/queue LVM operations
In-Reply-To: <alpine.LRH.2.11.1708040054310.9683@mail.ewheeler.net>
References: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
	<32ff399c-7a79-5beb-abd5-d5dbad1486db@redhat.com>
	<alpine.LRH.2.11.1708011720490.9683@mail.ewheeler.net>
	<4c0a5ae7-2da4-7610-5d06-90d990bd41de@redhat.com>
	<6aac428d-2c55-4d7f-4ad1-ebcd3b6f2ca6@redhat.com>
	<alpine.LRH.2.11.1708040054310.9683@mail.ewheeler.net>
Message-ID: <57f54908-4289-0c67-a965-15a8832fd85a@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 4.8.2017 v 02:59 Eric Wheeler napsal(a):
> On Tue, 1 Aug 2017, Zdenek Kabelac wrote:
> 
>> Dne 1.8.2017 v 19:46 Zdenek Kabelac napsal(a):
>> Also what is probably worthy exercise:
>>
>> If you have thinLVs you want to 'remove' -
>>
>> Deactivate all such LVs in one 'lvchange -an' command upfront.
>> Then as next step remove all such LVs with one  'lvremove' command.
>>
>> Take a timed 'strace -ttt' and measure how much time is spend in actual
>> 'ioctl' and compare with the remaining time spend in lvm2 processing.
>>
>> Then summarize  the output and your time-expectation  - possibly open RFE BZ
>> for it.
> 
> Details below, but to summarize:
> 
> Total ioctl time:  0.018542 seconds.
> Total runtime:    11.922s
> 
> Is this want you were interested to see?  Volumes were deactivated first.
> 
> -Eric
> 
> ]# time strace -Tttt lvremove -f \
> /dev/data/2017-08-03_17-52-54_manual_ertz_0 \
> /dev/data/2017-08-03_17-52-56_manual_ertz_0 \
> /dev/data/2017-08-03_17-52-57_manual_ertz_0 \
> /dev/data/2017-08-03_17-52-59_manual_ertz_0 \
> /dev/data/2017-08-03_17-53-00_manual_ertz_0 \
> /dev/data/2017-08-03_17-53-02_manual_ertz_0 \
> /dev/data/2017-08-03_17-53-03_manual_ertz_0 2>&1|grep ioctl | tee t.t
> 
> 1501808047.817379 ioctl(6, DM_TABLE_STATUS, 0x55cfc11040b0) = 0 <0.000010>
> 1501808047.817435 ioctl(6, DM_DEV_STATUS, 0x55cfc11040b0) = 0 <0.000010>
> 1501808048.635303 ioctl(6, DM_DEV_STATUS, 0x55cfc11000a0) = -1 ENXIO (No such device or address) <0.000020>
> 1501808048.636528 ioctl(6, DM_DEV_STATUS, 0x55cfc11000a0) = -1 ENXIO (No such device or address) <0.000009>

Looking at this trace - it seems to be stack at full commit point since lvm2 
is using flushing status - this has been (assuming) mostly fixed with recent
lvm2 releases (unless I've overlooked something).

Can you please try to do similar trace with lvm2 >= 2.02.172 - these version 
should avoid using  'status' with flushing.

Regards

Zdenek



