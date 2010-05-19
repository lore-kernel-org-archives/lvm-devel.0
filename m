From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 19 May 2010 13:29:04 +0100
Subject: LVM2/liblvm .exported_symbols lvm2app.h lvm_base.c
In-Reply-To: <20100519115317.25417.qmail@sourceware.org>
References: <20100519115317.25417.qmail@sourceware.org>
Message-ID: <20100519122904.GD3991@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 19, 2010 at 11:53:17AM -0000, wysochanski at sourceware.org wrote:
> 	Bump the lvm2app version number to 3.

We discussed this and agreed not to do it.

That version number will only be incremented if there is a change that
makes existing compiled code incompatible with the new compiled
shared object.

Alasdair


