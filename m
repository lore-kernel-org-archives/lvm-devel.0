From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 19 May 2009 18:14:07 +0100
Subject: [PATCH] User lock query instead of activate_lv_excl
In-Reply-To: <4A12B876.3090802@redhat.com>
References: <4A12B876.3090802@redhat.com>
Message-ID: <20090519171407.GY5125@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, May 19, 2009 at 03:47:34PM +0200, Milan Broz wrote:
> User lock query instead of activate_lv_excl
 
Ack.

> -		if (vg_is_clustered(vg) && !activate_lv_excl(cmd, lv) &&
> -		    (force == PROMPT)) {
> -			if (yes_no_prompt("Logical volume \"%s\" is active on other "
> -					  "cluster nodes.  Really remove? [y/n]: ",
> -					  lv->name) == 'n') {

That was a useful message it would be nice to add back later, if the query function
can also indicate whether or not it's active locally.

Alasdair


