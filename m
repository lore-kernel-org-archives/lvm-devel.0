From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 09 Dec 2014 15:38:41 +0100
Subject: dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <5485D86C.9040800@kernel.dk>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>	<20141204153358.GA19315@redhat.com>
	<5481EB1C.4000202@kernel.dk>	<20141205183342.GA27397@redhat.com>	<alpine.DEB.2.02.1412061437430.19773@ware.dreamhost.com>	<5483B04D.5030606@kernel.dk>	<alpine.DEB.2.02.1412062028500.15919@ware.dreamhost.com>
	<5485D86C.9040800@kernel.dk>
Message-ID: <54870971.9060403@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/08/2014 05:57 PM, Jens Axboe wrote:
> On 12/06/2014 11:30 PM, Eric Wheeler wrote:
>> On Sat, 6 Dec 2014, Jens Axboe wrote:
>>> On 12/06/2014 03:40 PM, Eric Wheeler wrote:
>>>> On Fri, 5 Dec 2014, Mike Snitzer wrote:
>>>>>> I do wonder what the performance impact is on this for dm. Have you
>>>>>> tried a (worst case) test of writing blocks that are zero filled, but
>>>>>> with the last byte not being a zero?
>>>>
>>>> The additional overhead of worst-case should be (nearly) equal to the
>>>> simplest test case of dd if=/dev/zero of=/dev/thinp/vol.  In my testing
>>>> that was 1.4GB/s within KVM on an Intel Xeon(R) CPU E3-1230 V2 @
>>>> 3.30GHz.
>>>
>>> That seems way too slow for checking if it's zero or not... Memory
>>> bandwidth should be way higher than that. The line above, was that
>>> what you ran? How does it look with bs=4k or higher?
>>
>> In userspace I can get ~12GB/s, so I think the algorithm is sound.
>> dd might not be the right tool for this.
>
> It's straight forward looping through the vectors, it can't really work
> any other way. But we need to figure out why it's so slow...

May be a premature optimization without any supporting data, but as this 
will be a frequently running loop, it is worth optimizing.

Two tips:

1. Is the compiler unrolling loops?

Using inline bvec_kunmap_irq in the loop may prevent the compiler from 
doing so.

Try breaking the loop when *parch is non zero and calling it outside of 
loop only when i >= count.

2. The function is doing quite a lot of jumping around making CPU 
pipeline mostly useless.

Try using kernel's built-in memcmp, which I expect to be optimized, and 
compare with a zero-page.

Perhaps doing few useless bit-or ops for every write would be more 
effective than this constant jumping.

-- Martian


>
>>>  read : io=12233MB, bw=1432.7MB/s, iops=22922, runt=  8539msec
>>
>> Can you suggest the right fio commandline to test sequential writes if
>> all zeros?  I tried --zero_buffers but couldn't get it to write zeros,
>> writes kept going to disk.
>
> zero_buffers=1
> scramble_buffers=0
>
> should get you all zeroes.
>


