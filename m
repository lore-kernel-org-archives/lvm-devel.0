From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 10 Dec 2008 22:41:39 +0000
Subject: [PATCH 06/11] Remove archive_enable() calls after create_toolcontext() calls.
In-Reply-To: <1228932661-15662-6-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-5-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-6-git-send-email-dwysocha@redhat.com>
Message-ID: <20081210224139.GE24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 10, 2008 at 01:10:56PM -0500, Dave Wysochanski wrote:
> The archive_enable() call we remove
> here was using cmd->current_settings to set the 'archive' enable
> value.  

Does that make archive_enable() unused?

> -	if (!archive_init(cmd, dir, days, min)) {
> +	if (!archive_init(cmd, dir, days, min,
> +			  cmd->default_settings.archive)) {

Call archive_enable() here instead, or have archive_init() call it
internally or comment out the function as unused?

Alasdair
-- 
agk at redhat.com


