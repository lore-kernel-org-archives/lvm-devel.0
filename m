From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 11 Dec 2008 22:32:53 -0500
Subject: [PATCH 10/11] Remove redundant init_mirror_in_sync() call in init_lvm().
In-Reply-To: <20081211224105.GL24785@agk.fab.redhat.com>
References: <1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-5-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-6-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-7-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-8-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-9-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-10-git-send-email-dwysocha@redhat.com>
	<20081210225018.GF24785@agk.fab.redhat.com>
	<1228962585.10873.9.camel@localhost.localdomain>
	<20081211224105.GL24785@agk.fab.redhat.com>
Message-ID: <1229052774.20795.41.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2008-12-11 at 22:41 +0000, Alasdair G Kergon wrote:
> On Wed, Dec 10, 2008 at 09:29:45PM -0500, Dave Wysochanski wrote:

> > This is a good point.  We will have some global state and this needs
> > thought out.  We may need to export _apply_settings() or something like
> > it to reset the global state.  Or perhaps the global state should be
> > reset at the bottom of create_toolcontext()?
> > For the the handle re-use case of the existing lvmcmdlib.c, we do a
> > _apply_settings() in lvm_run_command() so the global state is reset. We
> > won't have lvm_run_command() to rely on for liblvm, but I guess we need
> > the equivalent.
>  
> I'm talking *new* handle here - in other words when creating a new handle
> the code must not rely upon pre-existing values of those static variables: it
> must initialise them.
> 

Are there other globals we need to worry about or do you think the
create/destroy/create handle scenario will work with the existing
variable resets in the code (e.g. _apply_settings())?


