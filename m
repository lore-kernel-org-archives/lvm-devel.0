From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 14 May 2009 11:33:31 +0200
Subject: [PATCH] Add escape sequence for ':' in command's PV list
In-Reply-To: <1242243809.2556.19.camel@f10-node1>
References: <4A0AAA51.8040609@redhat.com> <1242243809.2556.19.camel@f10-node1>
Message-ID: <4A0BE56B.2000508@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/13/2009 09:43 PM, Dave Wysochanski wrote:
> I know, it does not make sense to specify a pe range
> for pvcreate or vgcreate.  But shouldn't we be consistent, or at least
> very much clarify the arguments are different?  I can just imagine
> someone scripting something and then being surprised when they needed to
> quote only for lvcreate, pvmove, etc.

Hmm, then the question is, what should we do with single unescaped ':' if
it appears in pvcreate, vgcreate, e.g. "pvcreate /dev/a::b:c" -- the first
double one is OK, but what about the second single one? Should it be considered
as an input error then? (...probably giving the user a message like
"PE range definition not allowed here.")

Peter


