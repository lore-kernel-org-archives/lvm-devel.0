From: Milan Broz <mbroz@redhat.com>
Date: Thu, 15 Sep 2011 14:41:19 +0200
Subject: [PATCH] Fix #733320: fix rounding inconsistency between lvresize/lvreduce
In-Reply-To: <87zki6t4xf.fsf@aldalome.int.mornfall.net.>
References: <87zki6t4xf.fsf@aldalome.int.mornfall.net.>
Message-ID: <4E71F26F.70509@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/15/2011 01:34 PM, Petr Rockai wrote:
> we wan to round in the safe direction, regardless of whether we were
> called as lvresize or lvreduce. The attached patch implements that (and
> adds a regression test).

yes, that seems much more better.
ACK.

Milan


