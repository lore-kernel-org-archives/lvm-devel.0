From: David Teigland <teigland@redhat.com>
Date: Tue, 29 Oct 2019 09:58:02 -0500
Subject: Performance regression between V2_02_177 and V2_02_180
In-Reply-To: <1572338679419.1072@citrix.com>
References: <1571324396950.37136@citrix.com>
 <1572338679419.1072@citrix.com>
Message-ID: <20191029145802.GA25248@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 29, 2019 at 08:44:39AM +0000, Ben Sims wrote:
> I can confirm the performance regression, is caused my async io, turning
> this off in the lvm.conf gets back my performance.
> 
> We work in a libaio intensive environment, so there is contention for
> libaio ring.

That's interesting, I've never heard about aio from independent programs
running on the system interfering like that.  Apart from the observation,
have you read about this anywhere so I could understand it better?

> I'm wondering if libaio should be on by default?

It's possible that we should change the use_aio default to 0 if most cases
don't benefit (e.g. small number of PVs), or have contention as you've
seen.

> I notice that the new bcache is reading significantly more data 262144
> bytes (two blocks of 131072 bytes from /dev/sda ) compared to 28672
> bytes in 4k reads made in V2_02_177. Whats the rational for reading so
> much more data?

It seemed to be a reasonable balance between iops and size when testing
various combinations.

That said, the bcache.c io layer is being replaced and renamed soon since
there were some aspects of that code that weren't ideally suited for lvm.
That will be using smaller block sizes.

> The extra overhead of this io estimated with strace does not appear to
> account for the slow down, but perhaps the processing of this data does?

If you eliminate the aio contention you mentioned above, I wouldn't expect
the actual io to be a factor.

> I'm currently instrumenting the code, but thought i would ask on the
> mailing list.

There was a lot of transition churn that's best to avoid while doing test
comparisions.  I suggest testing with 2.02.176 as the old version, and
then using the latest releases from stable-2.02 and master branches.  I
think lvm with bcache was released too early, and there have been
significant fixes and improvements added in both branches.

Dave


