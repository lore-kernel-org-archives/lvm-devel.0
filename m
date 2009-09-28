From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 28 Sep 2009 15:25:31 +0100
Subject: Re: [PATCH 2/3] differentiate between S.I. and binary units in output
In-Reply-To: <20090928131758.GA26763@redhat.com>
References: <1253979227-28051-1-git-send-email-impulze@impulze.org>
	<1253979227-28051-2-git-send-email-impulze@impulze.org>
	<20090928124906.GD5351@agk-dp.fab.redhat.com>
	<20090928131758.GA26763@redhat.com>
Message-ID: <20090928142531.GF5351@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 28, 2009 at 09:17:59AM -0400, Mike Snitzer wrote:
> I agree that 500-byte sectors aren't meaningful but I added support for
> them a few months ago to be consistent, see:
> http://sources.redhat.com/git/?p=lvm2.git;a=commit;h=69da2ac0

Where's that in WHATS_NEW?

I'll probably take it back out: I can't think of any reason for supporting it
and confusing people.

Alasdair


