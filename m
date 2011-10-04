From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 4 Oct 2011 10:17:01 +0200 (CEST)
Subject: [PATCH v3 08/18] fsadm: Remove unnecessary modification of PATH variable
In-Reply-To: <4E8ABFFD.3000005@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-9-git-send-email-lczerner@redhat.com>
	<4E8ABFFD.3000005@redhat.com>
Message-ID: <alpine.LFD.2.00.1110041015370.4206@dhcp-27-109.brq.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 4 Oct 2011, Zdenek Kabelac wrote:

> Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
> > User (or the system) should be set properly so there is no need to
> > modify PATH variable. It also prevent us from setting appropriate PATH
> > before calling the fsadm.
> > 
> > Signed-off-by: Lukas Czerner<lczerner@redhat.com>
> > ---
> >   scripts/fsadm.sh |    3 ---
> >   1 files changed, 0 insertions(+), 3 deletions(-)
> > 
> > diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
> > index 2d5c6f9..a1044f7 100755
> > --- a/scripts/fsadm.sh
> > +++ b/scripts/fsadm.sh
> > @@ -37,9 +37,6 @@
> > 
> >   TOOL=$(basename "$0")
> > 
> > -_SAVEPATH=$PATH
> > -PATH=/sbin:/usr/sbin:/bin:/usr/sbin:$PATH
> > -
> >   # utilities
> >   TUNE_EXT=tune2fs
> >   RESIZE_EXT=resize2fs
> 
> 
> Move this patch out of the future set - it's for separate discussion.
> 
> Zdenek

So let the separate discussion begin!

-Lukas


