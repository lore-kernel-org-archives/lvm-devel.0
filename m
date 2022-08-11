From: Ming Hung Tsai <mtsai@redhat.com>
Date: Thu, 11 Aug 2022 17:27:01 +0800
Subject: thin pool zeroing/dump query
In-Reply-To: <CAFe+wq062=a8iFbqD=MjK20UTrvEcoKscWZn1V1nMfxYM3068A@mail.gmail.com>
References: <CAFe+wq062=a8iFbqD=MjK20UTrvEcoKscWZn1V1nMfxYM3068A@mail.gmail.com>
Message-ID: <CALjSBEuSq_vFy-Jm=-6sEYk_spODPNqGwwVM5MVXHx-MWFAjmQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Aug 11, 2022 at 3:38 PM Lakshmi Narasimhan Sundararajan
<lsundararajan@purestorage.com> wrote:
>
> 1/ Is it safe to run with thin pool chunks not zeroed? What's the recommendation?
> not zeroing chunks from within thin pools, allows for some perf benefits, but we see xfs complaining about unclean metadata sometimes.
>
> Our reasoning is as below. A discard happened to a range that unmapped the chunk, and then fs wrote only a portion, which now has junk data in unwritten but discard region from fs point of view.

It should be safe to run thin-pool without zeroing. Enable zeroing
prevents data leaks (i.e., accessing discarded data) but introduces
performance overhead. On the other hand, I don't think that fs should
check unwritten areas of a chunk, regardless of block zeroing. Did you
issue trim commands from the fs layer?

> 2/ Is it possible for thin_dump to return len that are smaller than the whole chunk?
> say for ex. chunk mapped at off 'x' with user data only upto 'u' but the thin chunk size is (c) which is greater than user data (u). In which case, is it possible for thin_dump to report an off 'x' with len 'u'? Or can we always expect thin_dump to report lengths that are a multiple of chunk size?

dm-thin allocates space in terms of fixed-size chunks, so the mappings
are always a multiple of the chunk size.


Ming-Hung Tsai

