From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 21 Oct 2009 12:04:48 -0400
Subject: [PATCH] Document --all option in man pages, cleanup lvdisplay/pvdisplay man page.
In-Reply-To: <20091021125147.GA10165@agk-dp.fab.redhat.com>
References: <4AD83740.5070704@redhat.com>
	<1256097493-7756-1-git-send-email-dwysocha@redhat.com>
	<20091021125147.GA10165@agk-dp.fab.redhat.com>
Message-ID: <1256141088.3127.8.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2009-10-21 at 13:51 +0100, Alasdair G Kergon wrote:
> On Tue, Oct 20, 2009 at 11:58:13PM -0400, Dave Wysochanski wrote:
> >  lvdisplay \- display attributes of a logical volume
> 
> > +.B lvdisplay \-\-columns | \-C
> 
> Still doesn't match the --help text, which shows which arguments
> go with which form of the command.
> 
> >  \fBlvs\fP (8) is an alternative that provides the same information 
> >  in the style of \fBps\fP (1).  \fBlvs\fP is recommended over
> > -\fBlvdisplay\fP.
> > +\fBlvdisplay\fP.  \fBlvdisplay --columns\fP is the equivalent
> > +of calling \fBlvs\fP.
> 
> Mention that under -C in the OPTIONS section.
> "Calling X is the equivalent of calling Y" ('Running' or 'Executing'?)
> or better, just "X is equivalent to Y".
>   
> >  .B lvs
> > +[\-a|\-\-all]
> 
> > +Process all logical volumes, even hidden/internal ones.
> 
> Replace 'process' with a more descriptive verb based on what
> 'lvs' does.
> 
> Replace 'hidden/internal' with a better description of what
> is meant.  I can spot no existing references to 'internal'
> in this context in the man pages, and only one to 'implemented by
> creating a hidden virtual device'.
> 

Agreed this needs clarification - Milan has mentioned the same thing.
I'm not sure how to clarify though given existing constraints.

We're using "--all" in the tools to display internal "LVs" but from the
user perspective, they cannot really do operations on "hidden" LVs, and
I don't think we want them to.  The internal definition of the "LV" is
different from the user's understanding of an "LV" (a user cannot create
an internal LV, etc).

What is really going on is we're allowing users to operate on top-level
LVs, or "simple LVs" via the tools, while internal or "complex" LVs we
are not.

I think we may need to explain to users this notion of
internal/hidden/complex LVs vs simple ones.  I will make a go at
explaining this via either the lvcreate man page or lvm man page.


