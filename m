From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 12 Dec 2008 00:07:13 +0000
Subject: Re: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
In-Reply-To: <1229013323.20795.3.camel@localhost.localdomain>
References: <20081211162552.29826.qmail@sourceware.org>
	<1229013323.20795.3.camel@localhost.localdomain>
Message-ID: <20081212000713.GR24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Dec 11, 2008 at 11:35:23AM -0500, Dave Wysochanski wrote:
> 
> > +/* simplify string emiting code */
> > +#define EMIT_PARAMS(p, str...)\
> > +	do {\

> Do we have to do a macro here?  Macros like this are harder to debug...

Indeed - but sometimes there's stuff that's just too awkward to do
as a function.  I don't mind this one - we have a similar one in the kernel
called DMEMIT - so long as it is correct:-)
 
Alasdair
-- 
agk at redhat.com


