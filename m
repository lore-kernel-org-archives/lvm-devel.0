From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 24 Jun 2010 12:50:36 -0400
Subject: [PATCH] minor lvchange option validation refactor
In-Reply-To: <87hbksvgty.fsf@twilight.int.mornfall.net.>
References: <87hbksvgty.fsf@twilight.int.mornfall.net.>
Message-ID: <1277398236.2529.3.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2010-06-24 at 12:57 +0200, Petr Rockai wrote:
> Hi,
> 
> I would normally check this in right away, but on a second thought
> (since I got the change wrong the first time), an extra reading of the
> patch can't hurt (just check with good old De Morgan's). It is passing
> testsuite (now).
> 
> Thanks!
>    Petr.
> 
> PS: I ran into this sorting through stale mail. I may have a few more
> such outlandish ideas as I sort through more of it.
> --

Ack.  Read it through, looks like a good refactor that clarifies the
code.


