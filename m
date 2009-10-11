From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Sun, 11 Oct 2009 19:20:35 +0200
Subject: [PATCH 02/11] debian: drop realtime
In-Reply-To: <20091010092104.GB26029@wavehammer.waldi.eu.org>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<ed17d1525f4431ee900974ee84df19a351b005b5.1255002311.git.fdinitto@redhat.com>
	<20091008232825.GQ3054@agk-dp.fab.redhat.com>
	<20091009150311.GE6904@wavehammer.waldi.eu.org>
	<20091009162448.GG3054@agk-dp.fab.redhat.com>
	<20091010092104.GB26029@wavehammer.waldi.eu.org>
Message-ID: <1255281635.10932.9.camel@cerberus.int.fabbione.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, 2009-10-10 at 11:21 +0200, Bastian Blank wrote:
> On Fri, Oct 09, 2009 at 05:24:48PM +0100, Alasdair G Kergon wrote:
> > On Fri, Oct 09, 2009 at 05:03:11PM +0200, Bastian Blank wrote:
> > > The code is not used. Why is it there?
> > This is an upstream development tree and instead of having multiple
> > branches, we keep the code in one place but exclude or disable code that
> > is not used.
> 
> The code
> * is enabled by default,
> * is unused in the published code since a long time and
> * is not marked in any way.
> => Can be removed.
> 
> >               The code that needed to use that particular feature has
> > not been finished.
> 
> Then it can be handled as part of that particular feature.
> 
> Bastian
> 

this patch should make everybody happy.

Sets realitime support off by default and still allow to have it
configurable for developers.

Fabio
-------------- next part --------------
A non-text attachment was scrubbed...
Name: realtime.diff
Type: text/x-patch
Size: 1313 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20091011/6d7b145c/attachment.bin>
