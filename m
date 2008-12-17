From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 17 Dec 2008 16:39:24 +0000
Subject: [PATCH 1/2] Move arg_* functions from toollib.c to lvmcmdline.c.
In-Reply-To: <1229530908-1543-1-git-send-email-dwysocha@redhat.com>
References: <1229530908-1543-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20081217163924.GF25976@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 17, 2008 at 11:21:47AM -0500, Dave Wysochanski wrote:
> In preparation for removing cmd->args.
> IMO, it makes more sense to put these accessor functions
> in the same location as the static array _the_args.
> Next patch will update arg_* functions to use _the_args[]
> directly and remove cmd->args.
 
Ack.

Alasdair
-- 
agk at redhat.com


