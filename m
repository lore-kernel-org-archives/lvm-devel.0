From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 21:30:36 -0500
Subject: [PATCH 11/11] Move initialization of cmd->fmt into init_formats().
In-Reply-To: <20081210225649.GG24785@agk.fab.redhat.com>
References: <1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-5-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-6-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-7-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-8-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-9-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-10-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-11-git-send-email-dwysocha@redhat.com>
	<20081210225649.GG24785@agk.fab.redhat.com>
Message-ID: <1228962636.10873.11.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Wed, 2008-12-10 at 22:56 +0000, Alasdair G Kergon wrote:
> On Wed, Dec 10, 2008 at 01:11:01PM -0500, Dave Wysochanski wrote:
> > diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
> > index 186a816..e66972c 100644
> > --- a/lib/commands/toolcontext.c
> > +++ b/lib/commands/toolcontext.c
> > @@ -787,6 +787,7 @@ static int _init_formats(struct cmd_context *cmd)
> >  			return 1;
> >  		}
> >  	}
> > +	cmd->fmt = cmd->default_settings.fmt;
> 
> Move up just before the 'return 1' above?
> 

Indeed, that's an error.  Nice catch.


