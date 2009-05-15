From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 15 May 2009 08:27:40 -0400
Subject: [PATCH] Add escape sequence for ':' in command's PV list
In-Reply-To: <1242389250.2506.6.camel@f10-node1>
References: <4A0AAA51.8040609@redhat.com>
	<1242243809.2556.19.camel@f10-node1>  <4A0BE56B.2000508@redhat.com>
	<1242329131.3943.111.camel@f10-node1>
	<1242389250.2506.6.camel@f10-node1>
Message-ID: <1242390460.2506.8.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2009-05-15 at 08:07 -0400, Dave Wysochanski wrote:
> On Thu, 2009-05-14 at 15:25 -0400, Dave Wysochanski wrote:
> > On Thu, 2009-05-14 at 11:33 +0200, Peter Rajnoha wrote: 
> > > On 05/13/2009 09:43 PM, Dave Wysochanski wrote:
> > > > I know, it does not make sense to specify a pe range
> > > > for pvcreate or vgcreate.  But shouldn't we be consistent, or at least
> > > > very much clarify the arguments are different?  I can just imagine
> > > > someone scripting something and then being surprised when they needed to
> > > > quote only for lvcreate, pvmove, etc.
> > > 
> > > Hmm, then the question is, what should we do with single unescaped ':' if
> > > it appears in pvcreate, vgcreate, e.g. "pvcreate /dev/a::b:c" -- the first
> > > double one is OK, but what about the second single one? Should it be considered
> > > as an input error then? (...probably giving the user a message like
> > > "PE range definition not allowed here.")
> > > 
> > 
> > At this point I'd lean towards just clarifing the difference in the
> > arguments for the commands (e.g. in man pages, etc).  See attached patch
> > for a stab at updating the man pages.  If we go this route, then your
> > patch is fine as is IMO.
> > 
> > Also, on IRC yesterday, Alasdair suggested a new built-in command to
> > escape names such as this 
> > 17:01:40 < deepthot> agk_: on the escaping, you mean someone would do something like: lvcreate -L 16M -n lvname vgname `lvmescape /dev/pname`?
> > 17:05:07 < agk_> almost:   lvmescape /dev/path   then they can append :4-10 on it
> > 
> > IMO, this is a good idea.  However, in the spirit of not getting too
> > sidetracked, I think if we add proper explanation, we can probably defer
> > adding the built-in command, which probably requires some design thought
> > (for example, how to specify whether it is a pvname, vgname, etc - they
> > may have different characters to escape, etc).  If you want to tackle
> > that too though, go for it.
> > 
> 
> Upon further thought, I agree with you Peter - let's reject the ":" in
> pvcreate/vgcreate commands and print a message about pe range not
> allowed in these commands.  This way the commands are all consistent -
> require a "::" if any pvname contains a ":" in any of the commands.
> 

Updated man page patch is attached.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0001-Update-man-pages-to-clarify-usage-of-PE-ranges-and.patch
Type: text/x-patch
Size: 5575 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090515/284e1366/attachment.bin>
