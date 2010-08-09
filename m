From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 9 Aug 2010 12:42:15 -0400
Subject: [RFC PATCH v2] change default alignment of pe_start to 1MB
In-Reply-To: <4C602CA1.3040406@redhat.com>
References: <20100805191001.GA27237@redhat.com>
	<20100806041138.GA29995@redhat.com> <4C602CA1.3040406@redhat.com>
Message-ID: <20100809164215.GA21397@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Aug 09 2010 at 12:28pm -0400,
Milan Broz <mbroz@redhat.com> wrote:

> On 08/06/2010 06:11 AM, Mike Snitzer wrote:
> > The following revised patch changes the LVM alignment detection
> > semantics to model what fdisk has elected to do:
> > - If the default value (1MB) is a multiple of the specified/detected
> >   alignment then just use the default.
> > - Otherwise, use the specified/detected value.
> > 
> > In practice this means we'll almost always use 1MB -- that is unless:
> > - the specified --dataalignment, MD's full stripe width, or the
> >   optimal_io_size exceeds 1MB
> > - the specified/detected value is not a power-of-2
> 
> patch not tested, but Ack for idea.
> (I just did independently the same for LUKS devices.)

Great.  And just one point of clarification: if --dataalignment is used
then the requested alignment is used (no additional logic is allowed to
change the requested value).

Mike


