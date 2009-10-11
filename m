From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Sun, 11 Oct 2009 19:29:36 +0200
Subject: [PATCH 04/11] debian: fix implicit pointer
In-Reply-To: <20091008233412.GS3054@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<3b7fddbbcca36451e4b8e3617ab54c6e5839877a.1255002311.git.fdinitto@redhat.com>
	<20091008233412.GS3054@agk-dp.fab.redhat.com>
Message-ID: <1255282176.10932.13.camel@cerberus.int.fabbione.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2009-10-09 at 00:34 +0100, Alasdair G Kergon wrote:
> On Thu, Oct 08, 2009 at 02:49:11PM +0200, Fabio M. Di Nitto wrote:
> > not sure why the ifdef does not fire, but this is a readline function
> > and must not be redefined
>  
> This hack was needed for compilation on some systems (functions renamed
> in library).
> 
> If there are other systems where it causes problems, then please
> send details.

This might very well be a bug in Debian toolchain/autotools/readline
because I can't trigger it on any of my systems.

Bastian, I'd like to investigate this further. Can you please me provide
me with details of your test machine? Debian SID? x86? x86_64? tool
chain version? etc.

Thanks
Fabio


