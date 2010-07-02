From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 2 Jul 2010 04:02:11 +0100
Subject: [PATCH] avoid scanning suspended & otherwise inaccessible devices
In-Reply-To: <87aaqcjjvc.fsf@twilight.int.mornfall.net.>
References: <87aaqcjjvc.fsf@twilight.int.mornfall.net.>
Message-ID: <20100702030211.GH23989@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jun 30, 2010 at 11:22:47PM +0200, Peter Rockai wrote:
> -	if (!l) {
> +	if (!l || ignore_suspended_devices()) {

I've committed a version of this limited to dm devices for now
which doesn't require vgscan to be run manually after a
temporarily-suspended device is encountered.

But I think even the modified version has some undesirable interaction
with the MISSING_PV logic.

I really don't want to invest much time in any of this because it's all
meant to get deprecated by some new approach...

Alasdair


