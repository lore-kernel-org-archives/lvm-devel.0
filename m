From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 24 Oct 2007 01:44:35 +0100
Subject: [PATCH] lvm2 support for detecting v1.x MD superblocks
In-Reply-To: <170fa0d20710230832v3313d38fmc646d89c1b990252@mail.gmail.com>
References: <170fa0d20710230832v3313d38fmc646d89c1b990252@mail.gmail.com>
Message-ID: <20071024004435.GD10006@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 23, 2007 at 11:32:56AM -0400, Mike Snitzer wrote:
> I've tested the attached patch to work on MDs with v0.90.0, v1.0,
> v1.1, and v1.2 superblocks.
 
I'll apply this, thanks, but need to add comments (or reference) to explain
what the hard-coded numbers are:

	sb_offset = (size - 8 * 2) & ~(4 * 2 - 1);
etc.

Alasdair
-- 
agk at redhat.com


