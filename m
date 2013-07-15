From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 15 Jul 2013 16:27:38 -0400 (EDT)
Subject: number conversion in lvm
In-Reply-To: <51E45A1E.2090105@redhat.com>
References: <alpine.LRH.2.02.1307121904020.15166@file01.intranet.prod.int.rdu2.redhat.com>
	<51E11494.2080505@redhat.com>
	<alpine.LRH.2.02.1307151556340.11390@file01.intranet.prod.int.rdu2.redhat.com>
	<51E45A1E.2090105@redhat.com>
Message-ID: <alpine.LRH.2.02.1307151626060.11390@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> > > > BTW. how is that function supposed to handle integer overflow - it
> > > > doesn't
> > > > seem to do that.
> > > > 
> > > 
> > > it returns  LONG_MIN/MAX for underflow/overflow - but assuming errno could
> > > be checked for ERANGE and fail command for this case instead.
> > > 
> > > Zdenek
> > 
> > The major problem is that the same function _get_int_arg parses both
> > 32-bit and 64-bit arguments. It would be natural to return error on
> > integer overflow but you can't because you don't know if the caller will
> > use the 32-bit value or the 64-bit value.
> > 
> > Another question is why there is av->i_value and av->ui_value when the
> > values are the same and not dependent on the sign? What if the value fits
> 
> There are separate function for checking sign and accepting signed ints
> (int_arg_with_sign) - otherwise if SIGN_MINUS is detect - log error
> is reported.
> 
> Zdenek

Why are there two values av->i_value and av->ui_value if they have the 
same value and the sign flag is stored separately in av->sign?

Mikulas


