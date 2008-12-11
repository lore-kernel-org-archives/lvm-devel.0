From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 11 Dec 2008 22:41:05 +0000
Subject: [PATCH 10/11] Remove redundant init_mirror_in_sync() call in init_lvm().
In-Reply-To: <1228962585.10873.9.camel@localhost.localdomain>
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
Message-ID: <20081211224105.GL24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 10, 2008 at 09:29:45PM -0500, Dave Wysochanski wrote:
> On Wed, 2008-12-10 at 22:50 +0000, Alasdair G Kergon wrote:
> > On Wed, Dec 10, 2008 at 01:11:00PM -0500, Dave Wysochanski wrote:
> > > _mirror_in_sync is statically initialized to 0 in lvm-globals.c,
> > > so no need to set it in init_lvm().  Only other callers that may
> > > set this are later in execution.
> > Can the statics be relied upon if a handle is created, then destroyed
> > then a new handle created within the same process?
> > It basically depends if that initial value is relied upon anywhere, or
> > if later code always sets this before using it.

> This is a good point.  We will have some global state and this needs
> thought out.  We may need to export _apply_settings() or something like
> it to reset the global state.  Or perhaps the global state should be
> reset at the bottom of create_toolcontext()?
> For the the handle re-use case of the existing lvmcmdlib.c, we do a
> _apply_settings() in lvm_run_command() so the global state is reset. We
> won't have lvm_run_command() to rely on for liblvm, but I guess we need
> the equivalent.
 
I'm talking *new* handle here - in other words when creating a new handle
the code must not rely upon pre-existing values of those static variables: it
must initialise them.

Alasdair
-- 
agk at redhat.com


