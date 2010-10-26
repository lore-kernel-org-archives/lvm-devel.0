From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 26 Oct 2010 14:29:45 +0100
Subject: [PATCH 2/5] Ensure seg is nonnull
In-Reply-To: <fcd9985806b259f3f056c9f473144e029b2b7c8a.1288097372.git.zkabelac@redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
	<fcd9985806b259f3f056c9f473144e029b2b7c8a.1288097372.git.zkabelac@redhat.com>
Message-ID: <20101026132945.GH29400@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 26, 2010 at 02:59:23PM +0200, Zdenek Kabelac wrote:
> +		if (!seg) {
> +			log_error(INTERNAL_ERROR "Segment is not selected.");

I don't mind assertions like this, but please describe the problem more
accurately in the message.  If this triggers, doesn't it mean we
have a corrupt segment list?  So say that.
"LV %s segment list corrupted: NULL struct lv_segment detected."

But isn't there a missing 'if (lv)' ?

Alasdair


