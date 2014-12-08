From: Jens Axboe <axboe@kernel.dk>
Date: Mon, 08 Dec 2014 09:57:16 -0700
Subject: dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <alpine.DEB.2.02.1412062028500.15919@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
	<20141204153358.GA19315@redhat.com> <5481EB1C.4000202@kernel.dk>
	<20141205183342.GA27397@redhat.com>
	<alpine.DEB.2.02.1412061437430.19773@ware.dreamhost.com>
	<5483B04D.5030606@kernel.dk>
	<alpine.DEB.2.02.1412062028500.15919@ware.dreamhost.com>
Message-ID: <5485D86C.9040800@kernel.dk>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/06/2014 11:30 PM, Eric Wheeler wrote:
> On Sat, 6 Dec 2014, Jens Axboe wrote:
>> On 12/06/2014 03:40 PM, Eric Wheeler wrote:
>>> On Fri, 5 Dec 2014, Mike Snitzer wrote:
>>>>> I do wonder what the performance impact is on this for dm. Have you
>>>>> tried a (worst case) test of writing blocks that are zero filled, but
>>>>> with the last byte not being a zero?
>>>
>>> The additional overhead of worst-case should be (nearly) equal to the
>>> simplest test case of dd if=/dev/zero of=/dev/thinp/vol.  In my testing
>>> that was 1.4GB/s within KVM on an Intel Xeon(R) CPU E3-1230 V2 @
>>> 3.30GHz.
>>
>> That seems way too slow for checking if it's zero or not... Memory
>> bandwidth should be way higher than that. The line above, was that
>> what you ran? How does it look with bs=4k or higher?
>
> In userspace I can get ~12GB/s, so I think the algorithm is sound.
> dd might not be the right tool for this.

It's straight forward looping through the vectors, it can't really work 
any other way. But we need to figure out why it's so slow...

>>  read : io=12233MB, bw=1432.7MB/s, iops=22922, runt=  8539msec
>
> Can you suggest the right fio commandline to test sequential writes if
> all zeros?  I tried --zero_buffers but couldn't get it to write zeros,
> writes kept going to disk.

zero_buffers=1
scramble_buffers=0

should get you all zeroes.

-- 
Jens Axboe


