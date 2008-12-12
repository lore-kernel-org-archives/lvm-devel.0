From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 12 Dec 2008 12:43:33 -0500
Subject: [PATCH] (1/2) new library interface for vg_read
In-Reply-To: <87iqppbvej.fsf@eriador.mornfall.net>
References: <87y6ypcn7l.fsf@eriador.mornfall.net>
	<1229028451.20795.22.camel@localhost.localdomain>
	<87iqppbvej.fsf@eriador.mornfall.net>
Message-ID: <1229103814.16499.14.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Fri, 2008-12-12 at 10:22 +0100, Petr Rockai wrote:
> Hi,
> 
> Dave Wysochanski <dwysocha@redhat.com> writes:
> > Can you clean up some of the return value prototypes so they use
> > uint32_t consistently for return values?  This includes
> > vg_check_status(), vg_read_error(), vg_exists(), and the flag
> > definitions.
> I have changed those, plus removed the warning you mentioned in other mail,
> I'll probably re-add separately later. I'm attaching new-changes and new-all,
> first just giving the diff against the previous version of the patch. I'm not
> sure I agree that they should all be uint32_t though, but I suppose it's a
> minor point.
> 

I'm not sure either - what's the argument for 'int' returns for API
calls?  More like standard C library calls?

The flag definitions you have are not consistent with others in
metadata-exported.h but honestly I am not sure what is clearer.  Do you
agree we should be consistent here or is there a reason not to?

Agreed that mostly these are minor points.  Consistency I think is the
main goal.


