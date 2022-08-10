From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Wed, 10 Aug 2022 22:55:38 +0530
Subject: thin pool zeroing/dump query
Message-ID: <CAFe+wq062=a8iFbqD=MjK20UTrvEcoKscWZn1V1nMfxYM3068A@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Team!
Good day everyone!

I wanted to check with you on the 2 items below.

1/ Is it safe to run with thin pool chunks not zeroed? What's the
recommendation?
not zeroing chunks from within thin pools, allows for some perf benefits,
but we see xfs complaining about unclean metadata sometimes.

Our reasoning is as below. A discard happened to a range that unmapped the
chunk, and then fs wrote only a portion, which now has junk data in
unwritten but discard region from fs point of view.

2/ Is it possible for thin_dump to return len that are smaller than the
whole chunk?
say for ex. chunk mapped at off 'x' with user data only upto 'u' but the
thin chunk size is (c) which is greater than user data (u). In which case,
is it possible for thin_dump to report an off 'x' with len 'u'? Or can we
always expect thin_dump to report lengths that are a multiple of chunk size?

As always, thank you for your inputs and clarifications.

Best regards
LN
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220810/43d06847/attachment.htm>
