From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 11 May 2009 12:29:07 +0100
Subject: [PATCH 1/7] Fix snapshot segment import to not use duplicate segments & replace.
In-Reply-To: <87r5ywrw72.fsf@eriador.mornfall.net>
References: <cover.1241620083.git.mbroz@redhat.com>
	<cover.1241620083.git.mbroz@redhat.com>
	<c09189aa621b29aa02b3c5b98fc65b900529b301.1241620083.git.mbroz@redhat.com>
	<87r5ywrw72.fsf@eriador.mornfall.net>
Message-ID: <20090511112907.GE7680@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, May 11, 2009 at 08:27:13AM +0200, Peter Rockai wrote:
> Milan Broz <mbroz@redhat.com> writes:
> > Simplify the code, snapshot segment is properly initialized
> > in text_import function now and do not need to be replaced
> > by vg_add_snapshot call.
> Looks OK, although it does duplicate part of the code.

Indeed - please avoid duplicating that code.

Alasdair

 


