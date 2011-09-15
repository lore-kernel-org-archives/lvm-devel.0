From: Milan Broz <mbroz@redhat.com>
Date: Thu, 15 Sep 2011 21:15:01 +0200
Subject: [PATCH] Fix #734193: divisibility issues with striped mirrors
In-Reply-To: <87vcsusz82.fsf@aldalome.int.mornfall.net.>
References: <87vcsusz82.fsf@aldalome.int.mornfall.net.>
Message-ID: <4E724EB5.2030102@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/15/2011 03:37 PM, Petr Rockai wrote:
> the divisibility requirement in the allocation code is needlessly (and
> incorrectly) strict, accounting not only for stripe layout but also for
> mirrors (which do not divide extents among themselves, though). The
> attached patch should remedy that. Regression test included.

The former reason for this line was, I think it still applies
https://bugzilla.redhat.com/show_bug.cgi?id=707779

If so, ack.

Milan


