From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 13 Nov 2011 01:56:11 +0000
Subject: LVM2 ./WHATS_NEW_DM man/dmsetup.8.in
In-Reply-To: <20111112224845.28164.qmail@sourceware.org>
References: <20111112224845.28164.qmail@sourceware.org>
Message-ID: <20111113015611.GA4396@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Nov 12, 2011 at 10:48:45PM -0000, zkabelac at sourceware.org wrote:
> 	Added at least a very simply info about some other targets.

You could mention the names of the complex targets, but please don't try to
document them in this man page as it would make it far too long and it's a
distraction because dmsetup just passes its input lines through untouched at
the moment so the formats are not anything to do with 'man dmsetup'.

Refer people to Documentation/device-mapper and concentrate on improving that
documentation.

(We should really be packaging that in /usr/share/doc actually until we have
proper section 4 man pages written.)

Alasdair


