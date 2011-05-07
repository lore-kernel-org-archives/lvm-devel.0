From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 7 May 2011 19:24:13 +0100
Subject: LVM2 tools/lvmcmdline.c liblvm/lvm_base.c lib/ ...
In-Reply-To: <20110507135019.1909.qmail@sourceware.org>
References: <20110507135019.1909.qmail@sourceware.org>
Message-ID: <20110507182412.GA9253@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, May 07, 2011 at 01:50:19PM -0000, mornfall at sourceware.org wrote:
> +	/* Set in/out stream buffering before glibc */

Please add more explanatory comments inline.

I mentioned this on IRC but there's been a trend towards not giving
explanations inline which I'd like to see reversed.  Patch headers
are becoming too long, containing information about the new version
of the code which should instead have been placed inline.

Alasdair


