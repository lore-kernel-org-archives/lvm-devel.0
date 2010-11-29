From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:38:22 +0000
Subject: [PATCH 28/29] Check type is not NULL before access
In-Reply-To: <1581e3f71c289f475b0d580154ec41c734ad3309.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<1581e3f71c289f475b0d580154ec41c734ad3309.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129213822.GL29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:32AM +0100, Zdenek Kabelac wrote:
> Check type before dereference and report internal error in case
> it's undefined and return from the function.
 
But that does *not* look to be an internal dm library error at the moment.

It's just a parameter to dm_report_init().

Alasdair


