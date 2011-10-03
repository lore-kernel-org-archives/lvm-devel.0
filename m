From: Lukas Czerner <lczerner@redhat.com>
Date: Mon, 3 Oct 2011 18:44:04 +0200 (CEST)
Subject: [PATCH v3 03/18] fsadm: Add simple configuration file
In-Reply-To: <4E81EE3E.3080005@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-4-git-send-email-lczerner@redhat.com>
	<4E81EE3E.3080005@redhat.com>
Message-ID: <alpine.LFD.2.00.1110031841070.4447@dhcp-27-109.brq.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 27 Sep 2011, Zdenek Kabelac wrote:

> Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
> > Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> > ---
> >  scripts/fsadm.sh |   30 ++++++++++++++++++++++++++++++
> >  1 files changed, 30 insertions(+), 0 deletions(-)
> > 
> > diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
> > index 58ff0ab..98921d3 100755
> > --- a/scripts/fsadm.sh
> > +++ b/scripts/fsadm.sh
> > @@ -88,6 +88,9 @@ PROCDEVICES="/proc/devices"
> >  PROCPARTITIONS="/proc/partitions"
> >  NULL="$DM_DEV_DIR/null"
> >  
> > +CONFIG_PATHS="/etc/fsadm.conf ~/fsadm.conf"
> > +CONFIG=
> > +
> 
> 
> Looks too complicated -  sourcing config file with some defines looks like
> better approach here  if you really think it's useful.
> 
> 
> Zdenek

I do not think we should or can support setting all the different
variables we are using in fsadm via configuration file. That is why I
choose to only have strictly defined options in configuration file. This
way we have absolute control over what is configured via the
configuration file, which is the right approach.

Thanks!
-Lukas

> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 


