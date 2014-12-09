From: Jens Axboe <axboe@kernel.dk>
Date: Tue, 09 Dec 2014 08:41:59 -0700
Subject: dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <548715D2.1000509@kernel.dk>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
	<20141204153358.GA19315@redhat.com> <5481EB1C.4000202@kernel.dk>
	<20141205183342.GA27397@redhat.com>
	<alpine.DEB.2.02.1412061437430.19773@ware.dreamhost.com>
	<5483B04D.5030606@kernel.dk>
	<alpine.DEB.2.02.1412062028500.15919@ware.dreamhost.com>
	<5485D86C.9040800@kernel.dk>
	<alpine.DEB.2.02.1412082258460.10718@ware.dreamhost.com>
	<548715D2.1000509@kernel.dk>
Message-ID: <54871847.6020009@kernel.dk>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/09/2014 08:31 AM, Jens Axboe wrote:
> On 12/09/2014 01:02 AM, Eric Wheeler wrote:
>> On Fri, 5 Dec 2014, Mike Snitzer wrote:
>>> I do wonder what the performance impact is on this for dm. Have you
>>> tried a (worst case) test of writing blocks that are zero filled,
>>
>> Jens, thank you for your help w/ fio for generating zeroed writes!
>> Clearly fio is superior to dd as a sequential benchmarking tool; I was
>> actually able to push on the system's memory bandwidth.
>>
>> Results:
>>
>> I hacked block/loop.c and md/dm-thin.c to always call
>> bio_is_zero_filled()
>> and then complete without writing to disk, regardless of the return value
>> from bio_is_zero_filled().  In loop.c this was done in
>> do_bio_filebacked(), and for dm-thin.c this was done within
>> provision_block().
>>
>> This allows us to compare the performance difference between the simple
>> loopback block device driver vs the more complex dm-thinp implementation
>> just prior to block allocation.  These benchmarks give us a sense of how
>> performance differences relate between bio_is_zero_filled() and block
>> device implementation complexity, in addition to the raw performance of
>> bio_is_zero_filled in best- and worst-case scenarios.
>>
>> Since we always complete without writing after the call to
>> bio_is_zero_filled, regardless of the bio's content (all zeros or
>> not), we
>> can benchmark the difference in the common use case of random data, as
>> well as the edge case of skipping writes for bio's that contain all zeros
>> when writing to unallocated space of thin-provisioned volumes.
>>
>> These benchmarks were performed under KVM, so expect them to be lower
>> bounds due to overhead.  The hardware is a Intel(R) Xeon(R) CPU
>> E3-1230 V2
>> @ 3.30GHz.  The VM was allocated 4GB of memory with 4 cpu cores.
>>
>> Benchmarks were performed using fio-2.1.14-33-gf8b8f
>>   --name=writebw
>>   --rw=write
>>   --time_based
>>   --runtime=7 --ramp_time=3
>>   --norandommap
>>   --ioengine=libaio
>>   --group_reporting
>>   --direct=1
>>   --bs=1m
>>   --filename=/dev/X
>>   --numjobs=Y
>>
>> Random data was tested using:
>>    --zero_buffers=0 --scramble_buffers=1
>>
>> Zeroed data was tested using:
>>    --zero_buffers=1 --scramble_buffers=0
>>
>> Values below are from aggrb.
>>
>>                dm-thinp (MB/s)   loopback (MB/s)   loop faster by
>> factor of
>> ==============+======================================================
>> random jobs=4 | 18496.0          33522.0           1.68x
>> zeros  jobs=4 |  8119.2           9767.2           1.20x
>> ==============+======================================================
>> random jobs=1 |  7330.5          12330.0           1.81x
>> zeros  jobs=1 |  4965.2           6799.9           1.11x
>
> This looks more reasonable in terms of throughput.
>
> One major worry here is that checking every write is blowing your cache,
> so you could have a major impact on performance in general. Even for
> O_DIRECT writes, you are now accessing the memory. Have you looked into
> doing non-temporal memory compares instead? I think that would be the
> way to go.

So I found your patch in the thread. For each vector, use memcmp() 
instead and hope it does the right thing. You can compare with 
empty_zero_page. That should drastically cut down on the amount of hand 
rolled code you have in bio_is_zero_filled() at the moment.

-- 
Jens Axboe


