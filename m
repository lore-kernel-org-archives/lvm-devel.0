From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 21:20:39 -0500
Subject: [PATCH 06/11] Remove archive_enable() calls after create_toolcontext() calls.
In-Reply-To: <20081210224139.GE24785@agk.fab.redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-5-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-6-git-send-email-dwysocha@redhat.com>
	<20081210224139.GE24785@agk.fab.redhat.com>
Message-ID: <1228962039.10873.0.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Wed, 2008-12-10 at 22:41 +0000, Alasdair G Kergon wrote:
> On Wed, Dec 10, 2008 at 01:10:56PM -0500, Dave Wysochanski wrote:
> > The archive_enable() call we remove
> > here was using cmd->current_settings to set the 'archive' enable
> > value.  
> 
> Does that make archive_enable() unused?
> 
it's called from _apply_settings() too.

> > -	if (!archive_init(cmd, dir, days, min)) {
> > +	if (!archive_init(cmd, dir, days, min,
> > +			  cmd->default_settings.archive)) {
> 
> Call archive_enable() here instead, or have archive_init() call it
> internally or comment out the function as unused?
> 

I can call it internally.


