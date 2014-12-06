From: Eric Wheeler <lvm-dev@lists.ewheeler.net>
Date: Sat, 6 Dec 2014 14:40:36 -0800 (PST)
Subject: dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <20141205183342.GA27397@redhat.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
	<20141204153358.GA19315@redhat.com> <5481EB1C.4000202@kernel.dk>
	<20141205183342.GA27397@redhat.com>
Message-ID: <alpine.DEB.2.02.1412061437430.19773@ware.dreamhost.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 5 Dec 2014, Mike Snitzer wrote:
>> I do wonder what the performance impact is on this for dm. Have you
>> tried a (worst case) test of writing blocks that are zero filled, but
>> with the last byte not being a zero?

The additional overhead of worst-case should be (nearly) equal to the 
simplest test case of dd if=/dev/zero of=/dev/thinp/vol.  In my testing 
that was 1.4GB/s within KVM on an Intel Xeon(R) CPU E3-1230 V2 @ 3.30GHz.

I could see where really fast storage that can obtain 1.4gb/s might notice 
a performance regression---but for most use cases that is quite fast.

-Eric

> I haven't tested that yet, but I share your concern.  Does fio offer the
> ability to slap down a specific pattern like this?  If not is there a
> logical place to extend fio to enable this?




> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


