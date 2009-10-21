From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 21 Oct 2009 14:08:47 +0100
Subject: [PATCH] Enable (already implemented?) snapshots of mirrors
In-Reply-To: <1255637948.16495.26.camel@hydrogen.msp.redhat.com>
References: <1255637948.16495.26.camel@hydrogen.msp.redhat.com>
Message-ID: <20091021130847.GB10165@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Oct 15, 2009 at 03:19:08PM -0500, Jon Brassow wrote:
> I just wanted to get a feel for where things were at WRT snapshots of
> mirrors.  Pulling out the prevention check (patch provided below),
> things seem to work just fine.  Is there something I am missing?
 
Well the check was inserted because the code was untested.

All the newly-possible combinations of commands need to be tested before
it can be removed, and other 'unsupported' messages can be placed
where things don't work correctly.

(Basically you check through all the options of all the commands
one-by-one and test every aspect which might behave differently
in respect of snapshots of mirrors.  This includes checking the dmeventd
plugins as well as 'partial' VGs, and ensuring there are no ways of
manipulating the 'in-use' mirror that conflict with the fact it is
an origin, and ensuring display tools remain comprehensible.)

Alasdair


