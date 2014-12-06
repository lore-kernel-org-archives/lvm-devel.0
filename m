From: Eric Wheeler <lvm-dev@lists.ewheeler.net>
Date: Sat, 6 Dec 2014 14:33:19 -0800 (PST)
Subject: dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <20141204154324.GB19315@redhat.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
	<20141204153358.GA19315@redhat.com>
	<20141204154324.GB19315@redhat.com>
Message-ID: <alpine.DEB.2.02.1412061431300.19773@ware.dreamhost.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> Actually, given your: count = bv.bv_len / sizeof(uint64_t);
>
> My immediate concern was it would've truncated any partial contents of
> the bio_vec beyond the last uint64_t boundary.  Leading to possible
> false positive return from the function (because some contents weren't
> checked).

Understood.  I had always thought bio data was block-size aligned.

Out of curiosity, do you have examples of when this is not so?

>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


